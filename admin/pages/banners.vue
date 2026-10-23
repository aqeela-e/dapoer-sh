<template>
  <CrudPage title="Banner hero" subtitle="Banner dengan urutan terkecil dipakai sebagai judul, teks pengantar, dan tombol utama di bagian hero beranda." add-label="Tambah banner" table="banners" :fields="fields" :columns="columns" :order-by="{ col: 'sort_order', asc: true }" :defaults="{ is_active: true }" />
</template>

<script setup lang="ts">
const fields = [
  { key: 'title', label: 'Judul', type: 'text', required: true },
  { key: 'subtitle', label: 'Teks pengantar', type: 'textarea' },
  { key: 'image_url', label: 'Gambar pendamping (opsional)', type: 'image', help: 'Tampil sebagai foto bulat kecil di hero. Foto besar di hero diambil dari produk unggulan.' },
  { key: 'cta_label', label: 'Teks tombol', type: 'text' },
  { key: 'cta_url', label: 'Tautan tombol', type: 'text', help: 'Contoh: /shop atau https://...' },
  { key: 'sort_order', label: 'Urutan tampil', type: 'number', min: 0, help: 'Banner dengan urutan terkecil tampil di hero' },
  { key: 'is_active', label: 'Aktif', type: 'bool' }
]
const columns = [
  { key: 'image_url', label: 'Gambar', type: 'image' },
  { key: 'title', label: 'Judul' },
  { key: 'sort_order', label: 'Urutan' },
  { key: 'is_active', label: 'Status', type: 'bool', toggle: true }
]
</script>