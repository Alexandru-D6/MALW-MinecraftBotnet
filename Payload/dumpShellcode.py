import os
import sys
import re

def main():

    if (len(sys.argv) != 2):
        print("Usage: python3 dumpShellcode.py <objdump file>")
        sys.exit(1)

    # command = os.popen("objdump -d " + sys.argv[1])
    shellcode = ""

    regex = re.compile(r"\s+[a-f0-9]+:\s+([a-f0-9 ]+)  .*")

    with open(sys.argv[1], "r") as command:
        while True:
            line = command.readline()
            if not line:
                break

            match = regex.match(line)
            if match:
                hexdump = match.group(1).strip()
                for hex in hexdump.split(" "):
                    shellcode += "\\x" + hex

    # # Search if there's any occurance of \x00
    if (shellcode.find("\\x00") != -1):
        print("Shellcode contains null bytes.")
        sys.exit(69)

    os.write(1, shellcode.encode())

if __name__ == "__main__":
    main()