function MessageBoxA("user32.dll");
function ExitProcess("kernel32.dll");

MessageBoxA(0,"Malware Downloaded!","Malware",0);
ExitProcess(0);