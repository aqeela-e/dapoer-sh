# Gabin Ice Cream

Monorepo dua aplikasi Nuxt 3 (Vue 3 + TypeScript) dengan satu database Supabase bersama.

- `storefront/` website pelanggan (port 3000)
- `admin/` dashboard admin (port 3001)
- `supabase/` migrasi, seed, dan `setup.sql` (gabungan keduanya)

## Menjalankan lokal

```
npm install
npm run dev
```

Sebelum itu, lakukan setup Supabase satu kali:

1. Buat project di supabase.com.
2. Buka SQL Editor, tempel isi `supabase/setup.sql`, lalu Run.
3. Buka Authentication > Users > Add user, buat akun admin (email dan password). Akun pertama otomatis menjadi admin.
4. Salin `.env.example` menjadi `.env` di root dan isi `SUPABASE_URL` dan `SUPABASE_ANON_KEY` (Project Settings > API, gunakan anon key, jangan service-role key).
5. Buka Admin > Pengaturan WhatsApp dan ganti nomor contoh dengan nomor asli.

`npm run dev` otomatis menyalin `.env` root ke kedua aplikasi.

## Aturan transaksi dan stok

- Stok berkurang saat status berpindah dari baru ke dikonfirmasi, diproses, dikirim, atau selesai.
- Stok dikembalikan saat status menjadi dibatalkan atau kembali ke baru.
- Klik WhatsApp tidak dihitung sebagai penjualan.
- Kode transaksi unik, sehingga transaksi tidak dihitung dua kali.
- Omzet bruto = jumlah subtotal item. Omzet bersih = bruto dikurangi diskon. Total diterima = omzet bersih ditambah biaya pengiriman.
- Hanya transaksi dikonfirmasi, diproses, dikirim, dan selesai yang masuk laporan.

## Deployment (Vercel)

Buat dua project dari repository yang sama:

| Project | Root Directory | Framework |
| --- | --- | --- |
| Storefront | `storefront` | Nuxt |
| Admin | `admin` | Nuxt |

Isi environment variables `SUPABASE_URL` dan `SUPABASE_ANON_KEY` di kedua project.

Checklist:

- [ ] `setup.sql` sudah dijalankan
- [ ] Akun admin dibuat
- [ ] Nomor WhatsApp asli diisi
- [ ] Bucket `gabin-media` ada dan publik
- [ ] Kedua project Vercel memakai root directory yang benar
- [ ] Login admin, tambah produk, dan catat transaksi diuji di environment produksi

Keamanan data ditegakkan oleh Row Level Security di database. Pengunjung hanya membaca data yang dipublikasikan, dan semua operasi tulis memerlukan akun admin.
