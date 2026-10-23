<template>
  <div>
    <section class="hero">
      <div class="hero-sky" aria-hidden="true">
        <svg class="sky-cloud c1" viewBox="0 0 200 80"><path d="M30 70 C8 70 6 44 28 42 C28 20 56 14 68 30 C78 10 112 12 118 34 C140 26 160 40 152 58 C170 56 180 70 160 70 Z" fill="#fff" /></svg>
        <svg class="sky-cloud c2" viewBox="0 0 200 80"><path d="M30 70 C8 70 6 44 28 42 C28 20 56 14 68 30 C78 10 112 12 118 34 C140 26 160 40 152 58 C170 56 180 70 160 70 Z" fill="#fff" /></svg>
        <svg class="sky-cloud c3" viewBox="0 0 200 80"><path d="M30 70 C8 70 6 44 28 42 C28 20 56 14 68 30 C78 10 112 12 118 34 C140 26 160 40 152 58 C170 56 180 70 160 70 Z" fill="#fff" /></svg>
        <i v-for="(s, i) in sprinkles" :key="i" class="spr" :style="s" />
      </div>
      <div class="wrap hero-grid">
        <div class="hero-copy">
          <span v-if="po" class="pill" v-reveal><i class="dot" :class="{ off: po.po_open === false }" />Next PO {{ fmtDate(po.po_start) }}</span>
          <p class="tagline" v-reveal="80">{{ state.settings.tagline || BRAND.tagline }}</p>
          <h1 class="hero-title"><span v-for="(w, i) in words" :key="i" class="w" :style="{ '--i': i }">{{ w }}</span></h1>
          <p class="lead" v-reveal="320">{{ banner?.subtitle || state.settings.hero_intro || 'Pilih rasa favoritmu dan pesan langsung lewat WhatsApp.' }}</p>
          <div class="row" v-reveal="440">
            <a v-if="isExternal(banner?.cta_url)" class="btn" :href="banner.cta_url" target="_blank" rel="noopener">{{ banner.cta_label || 'Pesan Sekarang' }}</a>
            <NuxtLink v-else :to="banner?.cta_url || '/shop'" class="btn">{{ banner?.cta_label || 'Pesan Sekarang' }}</NuxtLink>
            <a v-if="state.wa?.channel_url" class="btn ghost" :href="state.wa.channel_url" target="_blank" rel="noopener">WhatsApp Channel</a>
          </div>
        </div>
        <div class="stage" aria-hidden="false">
          <i class="stage-blob" />
          <svg class="stage-ring" viewBox="0 0 120 120" aria-hidden="true">
            <defs><path id="ringp" d="M60,60 m-44,0 a44,44 0 1,1 88,0 a44,44 0 1,1 -88,0" /></defs>
            <circle cx="60" cy="60" r="58" fill="#F8F7BA" stroke="#3A2E4F" stroke-width="2.5" />
            <text><textPath href="#ringp" startOffset="0">handmade • pre-order • gabin ice cream •</textPath></text>
            <circle cx="60" cy="60" r="20" fill="#F5D2D2" stroke="#3A2E4F" stroke-width="2.5" />
            <path d="M60 70 C47 62 49 51 55 51 C58 51 60 54 60 56 C60 54 62 51 65 51 C71 51 73 62 60 70 Z" fill="#E9A8A8" stroke="#3A2E4F" stroke-width="2.5" stroke-linejoin="round" />
          </svg>
          <div class="shot b" :class="{ empty: !images[1] && !images[0] }"><img v-if="images[1] || images[0]" :src="images[1] || images[0]" alt="Produk Gabin Ice Cream" fetchpriority="high"><LogoArt v-else /></div>
          <div class="shot a" :class="{ empty: !images[0] }"><img v-if="images[0]" :src="images[0]" alt="Produk Gabin Ice Cream" fetchpriority="high"><LogoArt v-else /></div>
          <img v-if="banner?.image_url" class="shot c" :src="banner.image_url" :alt="banner.title">
        </div>
      </div>
    </section>

    <section class="sec menu">
      <CloudEdge color="var(--cream)" :seed="3" />
      <div class="wrap">
        <header class="sec-head" v-reveal>
          <p class="tagline sm">Pilih favoritmu</p>
          <h2 class="h">Produk Unggulan</h2>
          <p class="sub">Rasa yang paling sering dicari pelanggan Gabin.</p>
        </header>
        <div v-if="cats.length" class="chips" v-reveal>
          <NuxtLink v-for="c in cats" :key="c.id" :to="'/shop?cat=' + c.id" class="chip">{{ c.name }}</NuxtLink>
        </div>
        <div v-if="loading" class="empty">Memuat produk...</div>
        <div v-else-if="!featured.length" class="empty">Produk unggulan akan segera hadir.</div>
        <div v-else class="grid">
          <ProductCard v-for="(p, i) in featured" :key="p.id" v-reveal="(i % 3) * 90" :p="p" @open="sel = p" />
        </div>
        <div class="center" v-reveal><NuxtLink to="/shop" class="btn ghost">Lihat Semua Rasa</NuxtLink></div>
      </div>
    </section>

    <section v-if="state.settings.about_story" class="sec story">
      <CloudEdge color="var(--pink)" :seed="8" />
      <div class="wrap story-grid">
        <div class="story-art" v-reveal>
          <i class="story-blob" />
          <div class="shot s1" :class="{ empty: !images[2] && !images[0] }"><img v-if="images[2] || images[0]" :src="images[2] || images[0]" alt="Produk Gabin Ice Cream" loading="lazy"><LogoArt v-else /></div>
        </div>
        <div v-reveal="120">
          <p class="tagline sm">Cerita kami</p>
          <h2 class="h">Cerita Gabin</h2>
          <div class="rich story-text" v-html="sanitize(state.settings.about_story)" />
        </div>
      </div>
    </section>

    <section v-if="po" class="sec posec">
      <CloudEdge color="var(--blue)" :seed="15" />
      <div class="wrap">
        <div class="po" v-reveal>
          <div class="po-date">
            <span class="po-k">Periode PO</span>
            <strong>{{ fmtDate(po.po_start) }}<template v-if="po.po_end"> - {{ fmtDate(po.po_end) }}</template></strong>
            <span class="avail" :class="{ no: po.po_open === false }">{{ po.po_open === false ? 'PO ditutup' : 'PO dibuka' }}</span>
          </div>
          <div class="po-copy">
            <h2>{{ po.title }}</h2>
            <div class="rich" v-html="sanitize(po.body)" />
            <p v-if="po.delivery_estimate" class="meta">Estimasi pengiriman: {{ po.delivery_estimate }}</p>
            <NuxtLink to="/po" class="btn">Lihat detail PO</NuxtLink>
          </div>
        </div>
      </div>
    </section>

    <section v-if="testis.length" class="sec testi-sec last">
      <CloudEdge color="var(--cream)" :seed="21" />
      <div class="wrap">
        <header class="sec-head" v-reveal>
          <p class="tagline sm">Dari pelanggan</p>
          <h2 class="h">Kata Mereka</h2>
        </header>
        <div class="proof">
          <button v-for="(t, i) in testis" :key="t.id" v-reveal="(i % 4) * 80" type="button" class="proof-item" :class="'tone-' + (i % 4)" :aria-label="'Perbesar testimoni ' + t.name" @click="zoom = t">
            <img :src="t.image_url" :alt="'Testimoni dari ' + t.name" loading="lazy" decoding="async">
          </button>
        </div>
      </div>
    </section>
    <ImageLightbox :src="zoom?.image_url || null" :alt="zoom ? 'Testimoni dari ' + zoom.name : ''" @close="zoom = null" />

    <Teleport to="body"><ProductModal v-if="sel" :p="sel" @close="sel = null" /></Teleport>
  </div>
</template>

<script setup lang="ts">
const sb = useSb()
const { state } = useWa()
const loading = ref(true)
const featured = ref<any[]>([])
const cats = ref<any[]>([])
const testis = ref<any[]>([])
const banner = ref<any>(null)
const po = ref<any>(null)
const sel = ref<any>(null)
const zoom = ref<any>(null)
const { images } = useShowcase()

const isExternal = (u?: string) => !!u && /^https?:/i.test(u)
const fmtDate = (d?: string) => (d ? new Date(d + 'T00:00:00').toLocaleDateString('id-ID', { day: 'numeric', month: 'long' }) : '')
const words = computed(() => (banner.value?.title || 'Es krim yang bikin harimu lebih manis').split(/\s+/))

const sprinkles = [
  { left: '6%', top: '22%', background: '#E9A8A8', transform: 'rotate(28deg)' },
  { left: '14%', top: '74%', background: '#8CC79A', transform: 'rotate(-40deg)' },
  { left: '44%', top: '12%', background: '#6FA9BF', transform: 'rotate(64deg)' },
  { left: '52%', top: '84%', background: '#E9A8A8', transform: 'rotate(-12deg)' },
  { left: '92%', top: '16%', background: '#8CC79A', transform: 'rotate(40deg)' },
  { left: '88%', top: '78%', background: '#6FA9BF', transform: 'rotate(-58deg)' },
  { left: '33%', top: '46%', background: '#fff', transform: 'rotate(18deg)' },
  { left: '70%', top: '8%', background: '#E9A8A8', transform: 'rotate(-30deg)' }
]

onMounted(async () => {
  const now = new Date().toISOString()
  const [p, c, t, b, a] = await Promise.all([
    sb.from('products').select(PRODUCT_SELECT).eq('is_published', true).eq('is_archived', false).eq('is_featured', true).order('sort_order').limit(8),
    sb.from('categories').select('*').eq('is_active', true).order('sort_order'),
    sb.from('testimonials').select('*').eq('is_active', true).order('sort_order').limit(12),
    sb.from('banners').select('*').eq('is_active', true).order('sort_order').limit(1),
    sb.from('announcements').select('*').eq('is_active', true).eq('is_po', true).eq('placement', 'home').lte('starts_at', now).or(`ends_at.is.null,ends_at.gte.${now}`).order('starts_at', { ascending: false }).limit(1)
  ])
  featured.value = (p.data || []).map(normalizeProduct)
  cats.value = c.data || []
  testis.value = (t.data || []).filter((x: any) => x.image_url)
  banner.value = b.data?.[0] || null
  po.value = a.data?.[0] || null
  loading.value = false
})
</script>