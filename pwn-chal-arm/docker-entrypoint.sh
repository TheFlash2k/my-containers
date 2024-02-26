#!/bin/bash
# Author: @TheFlash2k

DEFAULT_PORT=8000
DEFAULT_CHAL_NAME="chal"
DEFAULT_BASE="ynetd"
DEFAULT_LOG_FILE="/var/log/chal.log"
DEFAULT_START_DIR="/app"
DEFAULT_FLAG_FILE="/app/flag.txt"

# Check if root:
if [ "$EUID" -eq 0 ]; then
    chown -R root:ctf-player /app/
fi

if [ -z "$OVERRIDE_USER" ]; then
    RUN_AS="ctf-player"
else
    # Check if user exists:
    if id "$OVERRIDE_USER" >/dev/null 2>&1; then
        RUN_AS="$OVERRIDE_USER"
    else
        RUN_AS="root"
    fi
fi

[ -z "$PORT" ] && PORT="$DEFAULT_PORT"
[ -z "$CHAL_NAME" ] && CHAL_NAME="$DEFAULT_CHAL_NAME"
[ -z "$BASE" ] && BASE="$DEFAULT_BASE"
[ -z "$LOG_FILE" ] && LOG_FILE="$DEFAULT_LOG_FILE"
[ -z "$START_DIR" ] && START_DIR="$DEFAULT_START_DIR"
[ -z "$FLAG_FILE" ] && FLAG_FILE="$DEFAULT_FLAG_FILE"

if [ "$BASE" != "ynetd" ] && [ "$BASE" != "socat" ]; then
    echo "Invalid utility: $BASE. Can only use ynetd or socat."
    exit 1
fi

if [ ! -f "/app/$CHAL_NAME" ]; then
    echo "No binary found: /app/$CHAL_NAME"
    exit 1
fi

if [ "$CHAL_NAME" != "$DEFAULT_CHAL_NAME" ]; then
    rm -f "/app/$DEFAULT_CHAL_NAME"
fi

if [ "$FLAG_FILE" != "$DEFAULT_FLAG_FILE" ]; then
    rm -f "$DEFAULT_FLAG_FILE"
    # Generate the symlink if `$FLAG_FILE_SYMLINK` is set.
    [ ! -z "$FLAG_FILE_SYMLINK" ] && ln -s "$FLAG_FILE" "$DEFAULT_FLAG_FILE"
fi

# self-yeet
rm -- "$0"

# Setting the permissions 550 on the /app/CHAL_NAME and 440 on flag
# Since we're not sure the flag is in / or /app (I sometimes add in / as well)
# So, I'm going to go for a wildcard:
chmod 550 "/app/$CHAL_NAME"
chmod 440 "$FLAG_FILE" /flag* &>/dev/null

if [ ! -z "$SETUID_USER" ]; then
    # default to root
    if ! id "$SETUID_USER" >/dev/null 2>&1; then
        SETUID_USER="root"
    fi
    chown "$SETUID_USER":"$SETUID_USER" "/app/$CHAL_NAME"
    chmod 4755 "/app/$CHAL_NAME"
fi

# Making the files read-only (only works if permissions allowed to the running container)
chattr +i "$FLAG_FILE" "/app/$CHAL_NAME" &>/dev/null 

###### QEMU SETUP #######
LIBRARY_PATH="/usr/arm-linux-gnueabihf";
EMULATOR="qemu-arm"
DEBUG=
if [ ! -z "$QEMU_GDB_DEBUG" ]; then
    if [ -z "$QEMU_GDB_PORT" ]; then
        echo "[DEBUG] No QEMU_GDB_PORT specified. Defaulting to 1024"
        QEMU_GDB_PORT=1024
    fi
    DEBUG=(-g $QEMU_GDB_PORT)
fi

ln -s "$LIBRARY_PATH/lib/ld-linux-armhf.so.3" "/usr/lib/ld-linux-armhf.so.3"
ln -s "$LIBRARY_PATH/lib/ld-linux.so.3" "/lib/ld-linux.so.3" &>/dev/null
ln -s "$LIBRARY_PATH/lib/libc.so.6" "/lib/libc.so.6" &>/dev/null

export LD_LIBRARY_PATH="$LIBRARY_PATH"
echo "[QEMU] using $EMULATOR and libaries @ $LIBRARY_PATH"

cd "$START_DIR";
echo "Running $CHAL_NAME in $(pwd) as $RUN_AS using $BASE and listening locally on $PORT"
if [ "$BASE" == "socat" ]; then
    rm -f /opt/ynetd
    LD_LIBRARY_PATH="$LD_LIBRARY_PATH" $EMULATOR $DEBUG -L "$LIBRARY_PATH" su $RUN_AS -c "/opt/socat tcp-l:$PORT,reuseaddr,fork, EXEC:\"/app/$CHAL_NAME\",stderr | tee -a $LOG_FILE"
else
    rm -f /opt/socat
    # -lt => cpu time in seconds. Keeps connection opened for max 10 seconds.
    # -se => stderr to redirect to socket
    LD_LIBRARY_PATH="$LD_LIBRARY_PATH" $EMULATOR $DEBUG -L "$LIBRARY_PATH" /opt/ynetd -lt 1 -p $PORT -u $RUN_AS -se y -d $START_DIR "/app/$CHAL_NAME" | tee -a $LOG_FILE
fi