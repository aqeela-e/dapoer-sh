<template>
  <CrudPage
    title="Produk"
    subtitle="Produk yang dipublikasikan tampil di beranda dan halaman Shop. Foto utama dipakai di kartu produk, hero, dan popup."
    add-label="Tambah produk"
    table="products"
    select="*, categories(name)"
    :fields="fields"
    :columns="columns"
    :filters="filters"
    :relations="relations"
    :links="links"
    :search-keys="['name', 'slug']"
    :order-by="{ col: 'sort_order', asc: true }"
    :defaults="{ po_status: 'ready', price: 0, stock: 0 }"
  />
</template>

<script setup lang="ts">
const fields = [
  { key: 'name', label: 'Nama produk', type: 'text', required: true },
  { key: 'slug', label: 'Slug', type: 'text', slugFrom: 'name', help: 'Kosongkan untuk dibuat otomatis', pattern: '^[a-z0-9-]+$', patternMsg: 'Hanya huruf kecil, angka, dan tanda hubung' },
  { key: 'description', label: 'Deskripsi singkat', type: 'textarea', help: 'Tampil di bawah nama produk pada kartu.' },
  { key: 'image_url', label: 'Foto utama', type: 'image', help: 'Disarankan foto produk berlatar putih, posisi produk di tengah.' },
  { key: 'category_id', label: 'Kategori', type: 'select', optionsFrom: { table: 'categories', label: 'name' } },
  { key: 'price', label: 'Harga dasar (Rp)', type: 'number', min: 0, required: true },
  { key: 'stock', label: 'Stok (dipakai jika tanpa varian)', type: 'number', min: 0 },
  { key: 'po_status', label: 'Status PO', type: 'select', required: true, options: [{ value: 'ready', label: 'Ready stock' }, { value: 'po', label: 'Pre-Order' }, { value: 'closed', label: 'PO ditutup' }] },
  { key: 'shipping_estimate', label: 'Estimasi pengiriman', type: 'text' },
  { key: 'storage_info', label: 'Informasi penyimpanan', type: 'textarea' },
  { key: 'notes', label: 'Catatan produk', type: 'textarea' },
  { key: 'historical_sold', label: 'Jumlah terjual', type: 'number', min: 0, help: 'Tampil di kartu produk sebagai "1,2rb Terjual". Kosongkan atau isi 0 untuk menyembunyikan.' },
  { key: 'sort_order', label: 'Urutan tampil', type: 'number', min: 0 },
  { key: 'is_published', label: 'Dipublikasikan', type: 'bool' },
  { key: 'is_featured', label: 'Produk unggulan (tampil di beranda dan hero)', type: 'bool' },
  { key: 'is_archived', label: 'Arsipkan produk', type: 'bool' }
]
const columns = [
  { key: 'image_url', label: 'Foto', type: 'image' },
  { key: 'name', label: 'Nama' },
  { key: 'categories.name', label: 'Kategori' },
  { key: 'price', label: 'Harga', type: 'money' },
  { key: 'stock', label: 'Stok' },
  { key: 'po_status', label: 'Status', type: 'badge', map: { ready: 'Ready stock', po: 'Pre-Order', closed: 'PO ditutup' }, tones: { ready: 'green', po: 'blue', closed: 'red' } },
  { key: 'is_published', label: 'Di website', type: 'bool', toggle: true, onLabel: 'Tampil', offLabel: 'Draft' },
  { key: 'is_archived', label: 'Arsip', type: 'bool' }
]
const filters = [
  { key: 'category_id', label: 'Semua kategori', optionsFrom: { table: 'categories', label: 'name' } },
  { key: 'is_published', label: 'Semua status', options: [{ value: 'true', label: 'Publik' }, { value: 'false', label: 'Draft' }] },
  { key: 'is_archived', label: 'Arsip', options: [{ value: 'true', label: 'Diarsipkan' }, { value: 'false', label: 'Tidak diarsipkan' }] }
]
const relations = [
  {
    name: 'variants',
    label: 'Varian (opsional)',
    table: 'product_variants',
    fk: 'product_id',
    fields: [
      { key: 'name', label: 'Nama varian', type: 'text', required: true },
      { key: 'price', label: 'Harga', type: 'number' },
      { key: 'stock', label: 'Stok', type: 'number' },
      { key: 'is_active', label: 'Aktif', type: 'bool' }
    ]
  },
  {
    name: 'gallery',
    label: 'Foto galeri',
    table: 'product_images',
    fk: 'product_id',
    fields: [{ key: 'url', label: 'Foto', type: 'image', required: true }]
  }
]
const links = [{ name: 'labels', label: 'Label produk', table: 'product_label_assignments', fk: 'product_id', other: 'label_id', source: 'product_labels' }]
</script>