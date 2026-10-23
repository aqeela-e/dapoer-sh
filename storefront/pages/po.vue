<template>
  <section class="page">
    <div class="page-hero">
      <div class="wrap">
        <p class="tagline sm">Jangan sampai kehabisan</p>
        <h1 class="h">Next PO dan Pengumuman</h1>
        <p class="sub">Jadwal pre-order dan info penting dari admin.</p>
      </div>
    </div>
    <div class="sec flat posec last">
      <CloudEdge color="var(--blue)" :seed="9" />
      <div class="wrap">
        <div v-if="loading" class="empty">Memuat pengumuman...</div>
        <div v-else-if="!items.length" class="empty">Belum ada pengumuman. Pantau terus halaman ini.</div>
        <div v-else class="cols">
          <article v-for="(a, i) in items" :key="a.id" v-reveal="(i % 3) * 90" class="soft-card" :class="'tone-' + (i % 4)">
            <img v-if="a.image_url" :src="a.image_url" :alt="a.title" class="soft-img" loading="lazy">
            <span v-if="a.is_po" class="avail" :class="{ no: !a.po_open }">{{ a.po_open ? 'PO dibuka' : 'PO ditutup' }}</span>
            <h3>{{ a.title }}</h3>
            <div class="rich" v-html="sanitize(a.body)" />
            <p v-if="a.po_start" class="meta">Periode: {{ fmt(a.po_start) }} - {{ fmt(a.po_end) }}</p>
            <p v-if="a.delivery_estimate" class="meta">Estimasi pengiriman: {{ a.delivery_estimate }}</p>
            <a v-if="a.cta_url" class="btn small" :href="a.cta_url" target="_blank" rel="noopener">{{ a.cta_label || 'Selengkapnya' }}</a>
          </article>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
const sb = useSb()
const loading = ref(true)
const items = ref<any[]>([])
const fmt = (d?: string) => (d ? new Date(d + 'T00:00:00').toLocaleDateString('id-ID', { day: 'numeric', month: 'long', year: 'numeric' }) : '')

onMounted(async () => {
  const now = new Date().toISOString()
  const { data } = await sb
    .from('announcements')
    .select('*')
    .eq('is_active', true)
    .lte('starts_at', now)
    .or(`ends_at.is.null,ends_at.gte.${now}`)
    .order('starts_at', { ascending: false })
  items.value = data || []
  loading.value = false
})
</script>