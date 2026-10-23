<template>
  <CrudPage
    title="Next PO dan Pengumuman"
    subtitle="Jadwal pre-order tampil sebagai popup saat pengunjung pertama membuka website dan di bagian Next PO. Tanpa data PO aktif, website menampilkan teks 'tanggal segera diumumkan'."
    add-label="Tambah pengumuman"
    table="announcements"
    :fields="fields"
    :columns="columns"
    :search-keys="['title']"
    :defaults="{ is_active: true, placement: 'home', po_open: true, starts_at: new Date().toISOString() }"
  />
</template>

<script setup lang="ts">
const fields = [
  { key: 'title', label: 'Judul', type: 'text', required: true },
  { key: 'body', label: 'Isi pengumuman', type: 'rich' },
  { key: 'image_url', label: 'Gambar (opsional)', type: 'image' },
  { key: 'placement', label: 'Tampil sebagai', type: 'select', required: true, options: [{ value: 'home', label: 'Bagian Next PO di beranda' }, { value: 'popup', label: 'Popup saat website dibuka' }], help: 'Jadwal PO (centang di bawah) otomatis ikut tampil di popup meskipun dipilih Beranda.' },
  { key: 'is_po', label: 'Ini jadwal Next PO (tampil di popup dengan tanggal dan status)', type: 'bool' },
  { key: 'po_open', label: 'PO dibuka', type: 'bool' },
  { key: 'po_start', label: 'Periode PO mulai', type: 'date' },
  { key: 'po_end', label: 'Periode PO selesai', type: 'date' },
  { key: 'delivery_estimate', label: 'Estimasi pengiriman', type: 'text' },
  { key: 'starts_at', label: 'Tayang mulai', type: 'datetime', required: true },
  { key: 'ends_at', label: 'Tayang sampai (kosong = tanpa batas)', type: 'datetime' },
  { key: 'cta_label', label: 'Teks tombol', type: 'text', help: 'Kosong = "Amankan Produkmu" (PO dibuka) atau "Pantau Jadwal PO" (PO ditutup).' },
  { key: 'cta_url', label: 'Tautan tombol', type: 'url', help: 'Kosong = menuju halaman Shop.' },
  { key: 'is_active', label: 'Aktif', type: 'bool' }
]
const columns = [
  { key: 'title', label: 'Judul' },
  { key: 'placement', label: 'Tampil', type: 'badge', map: { home: 'Beranda', popup: 'Popup' }, tones: { home: 'blue', popup: 'amber' } },
  { key: 'is_po', label: 'Next PO', type: 'bool' },
  { key: 'po_open', label: 'PO buka', type: 'bool' },
  { key: 'starts_at', label: 'Mulai', type: 'date' },
  { key: 'ends_at', label: 'Selesai', type: 'date' },
  { key: 'is_active', label: 'Status', type: 'bool', toggle: true }
]
</script>