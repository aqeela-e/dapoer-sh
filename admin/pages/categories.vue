<template>
  <CrudPage title="Kategori produk" subtitle="Dipakai sebagai filter di halaman Shop dan daftar kategori di beranda." add-label="Tambah kategori" table="categories" :fields="fields" :columns="columns" :order-by="{ col: 'sort_order', asc: true }" />
</template>

<script setup lang="ts">
const fields = [
  { key: 'name', label: 'Nama', type: 'text', required: true },
  { key: 'slug', label: 'Slug', type: 'text', slugFrom: 'name', help: 'Kosongkan untuk dibuat otomatis', pattern: '^[a-z0-9-]+$', patternMsg: 'Hanya huruf kecil, angka, dan tanda hubung' },
  { key: 'sort_order', label: 'Urutan tampil', type: 'number', min: 0 },
  { key: 'is_active', label: 'Aktif', type: 'bool' }
]
const columns = [
  { key: 'name', label: 'Nama' },
  { key: 'slug', label: 'Slug' },
  { key: 'sort_order', label: 'Urutan' },
  { key: 'is_active', label: 'Status', type: 'bool', toggle: true }
]
</script>