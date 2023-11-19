import os
import sys
import re

def main():

    if (len(sys.argv) != 2):
        print("Usage: python3 dumpShellcode.py <shellcode>")
        sys.exit(1)

    command = os.popen("objdump -d " + sys.argv[1])
    shellcode = ""

    regex = re.compile(r"\s+[a-f0-9]+:\s+([a-f0-9 ]+).*")
    # all lines are valid if does not contain "bad"
    validLine = re.compile(r"^((?!bad).)*$")
    while True:
        line = command.readline()
        if not line:
            break

        match = validLine.match(line)
        if match:
            # print(line, end="")
            match = regex.match(line)
            if match:
                hexdump = match.group(1).strip()
                for hex in hexdump.split(" "):
                    shellcode += "\\x" + hex
        else:
            break

    # # Search if there's any occurance of \x00
    if (shellcode.find("\\x00") != -1):
        print("Shellcode contains null bytes.")
        sys.exit(69)

    os.write(1, shellcode.encode())

if __name__ == "__main__":
    main()