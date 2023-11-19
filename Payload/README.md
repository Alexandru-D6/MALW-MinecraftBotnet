To create the payload we will make our lives easier by using the shellcode Compiler from: https://github.com/NytroRST/ShellcodeCompiler

Use it as follows:
 - ./ShellcodeCompiler_x64.exe -r payload.cpp -a _assembly.asm -p win_x86
 - nasm -f win32 _assembly.asm
 - py dumpShellcode.py ./_shellcode.bin
