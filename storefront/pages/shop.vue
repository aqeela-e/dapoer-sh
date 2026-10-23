<template>
  <section class="page">
    <div class="page-hero">
      <div class="wrap">
        <p class="tagline sm">Pilih favoritmu</p>
        <h1 class="h">Semua Rasa</h1>
        <p class="sub">Cari rasa favoritmu, lalu pesan lewat WhatsApp.</p>
      </div>
    </div>
    <div class="sec menu flat last">
      <CloudEdge color="var(--cream)" :seed="5" />
      <div class="wrap">
        <div class="tools">
          <input v-model="q" type="search" placeholder="Cari rasa atau produk" aria-label="Cari produk">
          <PillSelect v-model="sort" :options="sortOptions" aria-label="Urutkan produk" />
        </div>
        <div class="chips">
          <button type="button" class="chip" :class="{ on: !cat }" @click="cat = ''">Semua</button>
          <button v-for="c in cats" :key="c.id" type="button" class="chip" :class="{ on: cat === c.id }" @click="cat = c.id">{{ c.name }}</button>
        </div>
        <div v-if="loading" class="empty">Memuat produk...</div>
        <div v-else-if="!list.length" class="empty">Produk tidak ditemukan. Coba kata kunci atau kategori lain.</div>
        <div v-else class="grid">
          <ProductCard v-for="(p, i) in list" :key="p.id" v-reveal="(i % 3) * 80" :p="p" @open="sel = p" />
        </div>
      </div>
    </div>
    <Teleport to="body"><ProductModal v-if="sel" :p="sel" @close="sel = null" /></Teleport>
  </section>
</template>

<script setup lang="ts">
const sb = useSb()
const route = useRoute()
const loading = ref(true)
const products = ref<any[]>([])
const cats = ref<any[]>([])
const q = ref('')
const cat = ref(String(route.query.cat || ''))
const sort = ref('rec')
const sel = ref<any>(null)
const sortOptions = [
  { value: 'rec', label: 'Rekomendasi' },
  { value: 'low', label: 'Harga terendah' },
  { value: 'high', label: 'Harga tertinggi' },
  { value: 'az', label: 'Nama A-Z' }
]

const list = computed(() => {
  let r = products.value.filter((p) => (!cat.value || p.category_id === cat.value) && p.name.toLowerCase().includes(q.value.toLowerCase()))
  if (sort.value === 'low') r = [...r].sort((a, b) => a.minPrice - b.minPrice)
  if (sort.value === 'high') r = [...r].sort((a, b) => b.minPrice - a.minPrice)
  if (sort.value === 'az') r = [...r].sort((a, b) => a.name.localeCompare(b.name))
  return r
})

onMounted(async () => {
  const [p, c] = await Promise.all([
    sb.from('products').select(PRODUCT_SELECT).eq('is_published', true).eq('is_archived', false).order('sort_order'),
    sb.from('categories').select('*').eq('is_active', true).order('sort_order')
  ])
  products.value = (p.data || []).map(normalizeProduct)
  cats.value = c.data || []
  loading.value = false
})
</script>