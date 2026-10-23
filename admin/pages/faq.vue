<template>
  <CrudPage
    title="FAQ chatbot"
    subtitle="Pertanyaan dan jawaban di sini menjadi bahan jawaban chatbot di website. Pertanyaan yang ditandai akan muncul sebagai tombol cepat."
    add-label="Tambah FAQ"
    table="faqs"
    select="*, faq_categories(name)"
    :fields="fields"
    :columns="columns"
    :filters="filters"
    :search-keys="['question', 'answer']"
    :order-by="{ col: 'sort_order', asc: true }"
    :defaults="{ is_active: true, show_on_home: false }"
    reorder
  />
</template>

<script setup lang="ts">
const fields = [
  { key: 'question', label: 'Pertanyaan', type: 'text', required: true },
  { key: 'answer', label: 'Jawaban', type: 'rich', required: true, help: 'Tulis singkat dan jelas. Chatbot juga mencocokkan kata kunci dari pertanyaan dan jawaban.' },
  { key: 'category_id', label: 'Kategori FAQ', type: 'select', optionsFrom: { table: 'faq_categories', label: 'name' } },
  { key: 'sort_order', label: 'Urutan tampil', type: 'number', min: 0 },
  { key: 'is_active', label: 'Aktif (dipakai chatbot)', type: 'bool' },
  { key: 'show_on_home', label: 'Jadikan pertanyaan cepat di chatbot', type: 'bool' }
]
const columns = [
  { key: 'sort_order', label: 'Urutan' },
  { key: 'question', label: 'Pertanyaan' },
  { key: 'faq_categories.name', label: 'Kategori' },
  { key: 'show_on_home', label: 'Tombol cepat', type: 'bool' },
  { key: 'is_active', label: 'Status', type: 'bool', toggle: true },
  { key: 'updated_at', label: 'Diperbarui', type: 'date' }
]
const filters = [
  { key: 'category_id', label: 'Semua kategori', optionsFrom: { table: 'faq_categories', label: 'name' } },
  { key: 'is_active', label: 'Semua status', options: [{ value: 'true', label: 'Aktif' }, { value: 'false', label: 'Nonaktif' }] }
]
</script>