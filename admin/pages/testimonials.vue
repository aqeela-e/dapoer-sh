<template>
  <CrudPage
    title="Testimoni"
    subtitle="Unggah screenshot chat pelanggan. Di website, testimoni tampil sebagai gambar dan bisa diperbesar."
    add-label="Tambah testimoni"
    table="testimonials"
    :fields="fields"
    :columns="columns"
    :search-keys="['name']"
    :order-by="{ col: 'sort_order', asc: true }"
    :defaults="{ is_active: true }"
    :fixed="{ name: 'Pelanggan', content: '-', rating: 5 }"
  />
</template>

<script setup lang="ts">
const fields = [
  { key: 'image_url', label: 'Screenshot testimoni', type: 'image', required: true, help: 'Pastikan nomor atau data pribadi pelanggan sudah disamarkan.' },
  { key: 'name', label: 'Keterangan internal (opsional)', type: 'text', help: 'Hanya untuk arsip, tidak tampil di website.' },
  { key: 'sort_order', label: 'Urutan tampil', type: 'number', min: 0 },
  { key: 'is_active', label: 'Tampilkan di website', type: 'bool' }
]
const columns = [
  { key: 'image_url', label: 'Screenshot', type: 'image', tall: true },
  { key: 'name', label: 'Keterangan' },
  { key: 'sort_order', label: 'Urutan' },
  { key: 'is_active', label: 'Status', type: 'bool', toggle: true }
]
</script>