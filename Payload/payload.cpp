function SHGetFolderPathA("shell32.dll");
function ExitProcess("kernel32.dll");

SHGetFolderPathA(0, 29, NULL, 0, 0x69696969);
ExitProcess(0);