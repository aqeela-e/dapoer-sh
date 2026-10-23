<template>
  <CrudPage title="Kategori FAQ" subtitle="Mengelompokkan pertanyaan di chatbot." add-label="Tambah kategori" table="faq_categories" :fields="fields" :columns="columns" :order-by="{ col: 'sort_order', asc: true }" :defaults="{ is_active: true }" />
</template>

<script setup lang="ts">
const fields = [
  { key: 'name', label: 'Nama kategori', type: 'text', required: true },
  { key: 'sort_order', label: 'Urutan tampil', type: 'number', min: 0 },
  { key: 'is_active', label: 'Aktif', type: 'bool' }
]
const columns = [
  { key: 'name', label: 'Nama' },
  { key: 'sort_order', label: 'Urutan' },
  { key: 'is_active', label: 'Status', type: 'bool', toggle: true }
]
</script>