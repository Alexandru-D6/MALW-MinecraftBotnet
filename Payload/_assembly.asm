; Shellcode generated using Shellcode Compiler                         
; https://github.com/NytroRST/ShellcodeCompiler                    

xor ecx, ecx                                                           
mov eax, fs:[ecx + 0x30]               ; EAX = PEB                     
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
mov ax, 0x6c6c
push eax
push 0x642e3233
push 0x72657375
push esp                               ; String on the stack           
call [esp + 16]
add esp, 12
push eax                               ; DLL base on the stack         

xor eax, eax
mov eax, 0x2341786f
push eax
sub dword [esp + 3], 0x23
push 0x42656761
push 0x7373654d
push esp                               ; String on the stack            
push dword [esp + 16] 
call [esp + 28]
add esp, 12
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
push eax                               ; Function address on the stack 

xor eax, eax
mov eax, 0x23216465
push eax
sub dword [esp + 3], 0x23
push 0x64616f6c
push 0x6e776f44
push 0x20657261
push 0x776c614d
push esp

xor eax, eax
mov eax, 0x23657261
push eax
sub dword [esp + 3], 0x23
push 0x776c614d
push esp

xor eax, eax
push eax
push dword [ESP + 4]
push dword [ESP + 20]
xor eax, eax
push eax
call [ESP + 56]
add ESP, 36
xor eax, eax
push eax
call [ESP + 4]
