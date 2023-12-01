To create the payload we will make our lives easier by using the shellcode Compiler from: https://github.com/NytroRST/ShellcodeCompiler

Use it as follows:
 - ./ShellcodeCompiler_x64.exe -r payload.cpp -a _assembly.asm -p win_x86
    * You must manually modify the assembly in order to fix it:
        + mov eax, fs:[ecx + 0x30]
        + mov eax, [fs:ecx + 0x30]
 - nasm -g -f win32 _assembly.asm -o _assembly.o
 - ld -g -mi386pe _assembly.o -o _assembly.exe
