<template>
  <section class="page">
    <div class="page-hero">
      <div class="wrap">
        <p class="tagline sm">Kami siap membantu</p>
        <h1 class="h">Hubungi Kami</h1>
        <p class="sub">{{ fallbackMessage || 'Pilih salah satu admin di bawah ini.' }}</p>
      </div>
    </div>
    <div class="sec flat ask last">
      <CloudEdge color="var(--green)" :seed="18" />
      <div class="wrap cols">
        <div v-for="(n, i) in numbers" :key="n.key" v-reveal="i * 90" class="soft-card" :class="'tone-' + i">
          <span class="avail">{{ n.key === 'main' ? 'Utama' : 'Alternatif' }}</span>
          <h3>{{ n.label }}</h3>
          <p>{{ n.key === 'main' ? 'Untuk pemesanan dan pertanyaan produk.' : 'Untuk bantuan, atau kalau admin utama belum sempat membalas.' }}</p>
          <a class="btn wa" :href="link(n.number, n.message)" target="_blank" rel="noopener"><WaIcon />Chat {{ n.label }}</a>
        </div>
        <div v-reveal="180" class="soft-card tone-2">
          <h3>Pengiriman</h3>
          <p>{{ state.settings.shipping_info || 'Detail pengiriman dikonfirmasi admin.' }}</p>
        </div>
        <div v-if="state.wa?.channel_url" v-reveal="260" class="soft-card tone-3">
          <h3>WhatsApp Channel</h3>
          <p>Info PO dan rasa terbaru.</p>
          <a class="btn" :href="state.wa.channel_url" target="_blank" rel="noopener">Gabung Channel</a>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
const { numbers, link, fallbackMessage, state } = useWa()
</script>