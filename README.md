# Praktikum Minggu 5: Pemrograman Solidity Lanjut
**Mata Kuliah:** Teknologi Blockchain  
**Topik:** Tipe Data Kompleks, Access Control, dan Error Handling  

## Implementasi Fitur:
1. Penambahan array `ownershipHistory` pada `struct MediaWork` untuk mencatat riwayat pemindahan hak cipta.
2. Penambahan fungsi `transferCopyright(bytes32 _mediaId, address _newOwner)` dengan modifier akses kontrol `onlyCreator`.
3. Pengujian *error handling* custom error `UnauthorizedAccess` saat fungsi dipanggil oleh selain pemilik karya.

## Bukti Pengujian Error Handling (Remix IDE):
![Pengujian Error Handling](<Screenshot 2026-09-23 104637.png>)
