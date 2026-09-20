#!/usr/bin/env python3
import sys

def main():
    log_path = sys.argv[1] if len(sys.argv) > 1 else '/tmp/flutter_build.log'
    try:
        with open(log_path, 'r', errors='ignore') as f:
            lines = f.readlines()
    except Exception as e:
        print(f"Failed to read log: {e}")
        return

    indices = [i for i, l in enumerate(lines) if 'What went wrong' in l or 'FAILURE:' in l or 'error:' in l.lower()]
    if indices:
        start = max(0, indices[0] - 10)
        end = min(len(lines), indices[0] + 100)
        print(''.join(lines[start:end]))
    else:
        print(''.join(lines[-120:]))

if __name__ == '__main__':
    main()
