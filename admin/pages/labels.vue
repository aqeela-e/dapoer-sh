<template>
  <CrudPage title="Label produk" subtitle="Label kecil di foto produk, misalnya Best Seller atau Next PO." add-label="Tambah label" table="product_labels" :fields="fields" :columns="columns" :order-by="{ col: 'sort_order', asc: true }" :defaults="{ color: '#2563eb', is_active: true }" />
</template>

<script setup lang="ts">
const fields = [
  { key: 'name', label: 'Nama label', type: 'text', required: true },
  { key: 'color', label: 'Warna', type: 'color' },
  { key: 'sort_order', label: 'Urutan tampil', type: 'number', min: 0 },
  { key: 'is_active', label: 'Aktif', type: 'bool' }
]
const columns = [
  { key: 'name', label: 'Nama' },
  { key: 'color', label: 'Warna', type: 'color' },
  { key: 'sort_order', label: 'Urutan' },
  { key: 'is_active', label: 'Status', type: 'bool', toggle: true }
]
</script>