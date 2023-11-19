import os
import sys
import re

def main():

    if (len(sys.argv) != 2):
        print("Usage: python3 dumpShellcode.py <shellcode>")
        sys.exit(1)

    shellcode = sys.argv[1]
    with open(shellcode, "rb") as f:
        shellcode = f.read()

    finalShellcode = ""
    for char in shellcode:
        finalShellcode += "\\x" + f"{char:02x}"

    os.write(1, finalShellcode.encode())

if __name__ == "__main__":
    main()