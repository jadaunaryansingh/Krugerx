import os
import struct
import zipfile
import shutil

def patch_elf_16kb(file_bytes):
    # Check ELF magic: \x7fELF
    if not file_bytes.startswith(b'\x7fELF'):
        return file_bytes, 0

    # Must be 64-bit (EI_CLASS = 2 at offset 4)
    if file_bytes[4] != 2:
        return file_bytes, 0

    # Endianness (EI_DATA at offset 5): 1 = Little Endian
    is_little_endian = (file_bytes[5] == 1)
    endian_char = '<' if is_little_endian else '>'

    # E_PHOFF (Program Header table offset) at byte 32 (uint64)
    # E_PHENTSIZE (Program Header entry size) at byte 54 (uint16)
    # E_PHNUM (Number of Program Header entries) at byte 56 (uint16)
    e_phoff = struct.unpack(f'{endian_char}Q', file_bytes[32:40])[0]
    e_phentsize = struct.unpack(f'{endian_char}H', file_bytes[54:56])[0]
    e_phnum = struct.unpack(f'{endian_char}H', file_bytes[56:58])[0]

    data = bytearray(file_bytes)
    patched_count = 0

    for i in range(e_phnum):
        entry_offset = e_phoff + (i * e_phentsize)
        if entry_offset + 56 > len(data):
            break

        # Elf64_Phdr fields:
        # p_type (uint32) at entry_offset + 0
        # p_align (uint64) at entry_offset + 48
        p_type = struct.unpack(f'{endian_char}I', data[entry_offset : entry_offset + 4])[0]

        # PT_LOAD = 1
        if p_type == 1:
            p_align = struct.unpack(f'{endian_char}Q', data[entry_offset + 48 : entry_offset + 56])[0]
            if p_align < 16384:
                # Patch p_align to 16384 (0x4000)
                new_align_bytes = struct.pack(f'{endian_char}Q', 16384)
                data[entry_offset + 48 : entry_offset + 56] = new_align_bytes
                patched_count += 1

    return bytes(data), patched_count

def patch_apk(apk_path):
    print(f"Examining & patching 16KB ELF alignment for {apk_path}...")
    temp_apk = apk_path + '.tmp'
    total_patched = 0

    with zipfile.ZipFile(apk_path, 'r') as zin, zipfile.ZipFile(temp_apk, 'w') as zout:
        for item in zin.infolist():
            content = zin.read(item.filename)
            if item.filename.endswith('.so') and item.filename.startswith('lib/'):
                new_content, count = patch_elf_16kb(content)
                if count > 0:
                    print(f" -> Patched {item.filename}: {count} PT_LOAD segments aligned to 16384")
                    total_patched += count
                # Preserve permissions
                zout.writestr(item, new_content)
            else:
                zout.writestr(item, content)

    shutil.move(temp_apk, apk_path)
    print(f"[SUCCESS] Patched total {total_patched} ELF LOAD segments in {apk_path}")

if __name__ == '__main__':
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    apk = os.path.join(root, 'krugerx', 'build', 'app', 'outputs', 'flutter-apk', 'app-release.apk')
    if os.path.exists(apk):
        patch_apk(apk)
    
    downloads_apk = os.path.join(root, 'backend', 'Landingpage', 'static', 'downloads', 'krugerx-android.apk')
    if os.path.exists(downloads_apk):
        patch_apk(downloads_apk)
