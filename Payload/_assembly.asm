; Shellcode generated using Shellcode Compiler
; https://github.com/NytroRST/ShellcodeCompiler

xor ecx, ecx
mov eax, [fs:ecx + 0x30]               ; EAX = PEB
mov eax, [eax + 0xc]                   ; EAX = PEB->Ldr
mov esi, [eax + 0x14]                  ; ESI = PEB->Ldr.InMemOrder
lodsd                                  ; EAX = Second module
xchg eax, esi                          ; EAX = ESI, ESI = EAX
lodsd                                  ; EAX = Third(kernel32)
mov ebx, [eax + 0x10]                  ; EBX = Base address
mov edx, [ebx + 0x3c]                  ; EDX = DOS->e_lfanew
add edx, ebx                           ; EDX = PE Header
mov edx, [edx + 0x78]                  ; EDX = Offset export table
add edx, ebx                           ; EDX = Export table
mov esi, [edx + 0x20]                  ; ESI = Offset namestable
add esi, ebx                           ; ESI = Names table
xor ecx, ecx                           ; EXC = 0

Get_Function:

inc ecx                                ; Increment the ordinal
lodsd                                  ; Get name offset
add eax, ebx                           ; Get function name
cmp dword [eax], 0x50746547            ; GetP
jnz Get_Function
cmp dword [eax + 0x4], 0x41636f72      ; rocA
jnz Get_Function
cmp dword [eax + 0x8], 0x65726464      ; ddre
jnz Get_Function
mov esi, [edx + 0x24]                  ; ESI = Offset ordinals
add esi, ebx                           ; ESI = Ordinals table
mov cx, [esi + ecx * 2]                ; Number of function
dec ecx
mov esi, [edx + 0x1c]                  ; Offset address table
add esi, ebx                           ; ESI = Address table
mov edx, [esi + ecx * 4]               ; EDX = Pointer(offset)
add edx, ebx                           ; EDX = GetProcAddress

xor ecx, ecx                           ; ECX = 0
push ebx                               ; Kernel32 base address
push edx                               ; GetProcAddress
push ecx                               ; 0
push 0x41797261                        ; aryA
push 0x7262694c                        ; Libr
push 0x64616f4c                        ; Load
push esp                               ; LoadLibrary
push ebx                               ; Kernel32 base address
call edx                               ; GetProcAddress(LL)

add esp, 0xc                           ; pop LoadLibrary
pop ecx                                ; ECX = 0
push eax                               ; EAX = LoadLibrary

xor eax, eax
mov eax, 0x236c6c64
push eax
sub dword [esp + 3], 0x23
push 0x2e32336c
push 0x6c656873
push esp                               ; String on the stack
call [esp + 16]
add esp, 12
push eax                               ; DLL base on the stack

; GetProcAddress(shell32.dll, SHGetFolderPathA)

xor eax, eax                           ; EAX = 0
push eax                               ; NULL on the stack
push 0x41687461
push 0x50726564
push 0x6c6f4674
push 0x65474853
push esp                               ; String on the stack
push dword [esp + 24]
call [esp + 36]
add esp, 20
push eax                               ; Function address on the stack

xor eax, eax
mov eax, 0x23737365
push eax
sub dword [esp + 3], 0x23
push 0x636f7250
push 0x74697845
push esp                               ; String on the stack
push dword [esp + 32]
call [esp + 32]
add esp, 12

sub esp, 0xFC                          ; Allocate memory on the stack
push eax                               ; Function address on the stack
; load the memory address of register esp and add 0x100 to it, then push it on the stack
lea eax, [esp + 0x04]
push eax
xor eax, eax                            ; EAX = 0
push eax                                ; NULL on the stack
push 0x1d                               ; CSIDL_APPDATA
xor eax, eax                            ; EAX = 0
push eax                                ; NULL on the stack
call [ESP + 20]                         ; Call SHGetFolderPathA
xor eax, eax
push eax
call [ESP + 4]
