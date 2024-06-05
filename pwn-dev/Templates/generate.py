#!/usr/bin/env python3
import argparse

def create_fmt(start: int, end: int = 0, atleast: int = 10, max_len: int = -1, with_index: bool = False, specifier: str = "p", seperator: str = '|') -> bytes:
    end = start+atleast if end == 0 else end
    fmt = "{seperator}%{i}${specifier}" if not with_index else "{seperator}{i}=%{i}${specifier}"
    rt = ""
    for i in range(start, end+1): rt += fmt.format(i=i, specifier=specifier, seperator=seperator)
    ''' Making sure we always get a valid fmt in the max_len range '''
    if max_len <= 0: return rt.encode()
    rt = seperator.join(rt[:max_len].split(seperator)[:-1]) if rt[:max_len][-1] != specifier else rt[:max_len]
    return rt.encode()

if __name__ == "__main__":

    parser = argparse.ArgumentParser(prog='fmt-generator', description="Generate format string payloads for fuzzing")

    parser.add_argument('-s', '--start', required=True, type=int, help='The start of the buffer i.e. "n" in %%n$p')
    parser.add_argument('-e', '--end', type=int, default=0, help='The ending `n` of the format buffer (inclusive)')
    parser.add_argument('-a', '--atleast', type=int, default=10, help='Specifies how many specifiers must be printed atleast')
    parser.add_argument('-l', '--max-len', type=int, default=-1, dest='max_len', help='The maximum length of the format string')
    parser.add_argument('--with-index', action='store_true', dest='with_index', help='Prints the fmt payload with indexes if true i.e. n=%%n$p|n-1=%%n-1$p... (Normal: %%n$p|%%n-1$p)')
    parser.add_argument('--specifier', type=str, default="p", help='The format specifier to use in the payload.')
    parser.add_argument('--seperator', type=str, default="|", help='The seperator between each format specifier')
    parser.add_argument('--as-bytes', action='store_true', dest='as_bytes', help='Get the output in bytes (prefixed with b)')

    args = parser.parse_args()
    fmt = create_fmt(
        start=args.start,
        end=args.end,
        atleast=args.atleast,
        max_len=args.max_len,
        with_index=args.with_index,
        specifier=args.specifier,
        seperator=args.seperator
    )
    if not args.as_bytes: fmt = fmt.decode()
    print("%s" % fmt)

    pass
