<template>
  <footer class="foot">
    <CloudFooterLayers />
    <div class="foot-body">
      <div class="wrap foot-grid">
        <div class="foot-brand">
          <img src="/images/logo.png" :alt="BRAND.store" width="170" height="102" loading="lazy">
          <h3>{{ BRAND.name }}</h3>
          <p class="script">{{ state.settings.tagline || BRAND.tagline }}</p>
          <p>Es krim handmade, dipesan lewat WhatsApp.</p>
        </div>
        <nav class="foot-col" aria-label="Navigasi footer">
          <h4>Jelajahi</h4>
          <NuxtLink to="/shop">Semua Rasa</NuxtLink>
          <NuxtLink to="/po">Next PO</NuxtLink>
          <NuxtLink to="/contact">Kontak</NuxtLink>
        </nav>
        <div class="foot-col">
          <h4>Pesan &amp; Bantuan</h4>
          <a v-for="n in numbers" :key="n.key" :href="link(n.number, n.message)" target="_blank" rel="noopener">{{ n.label }}</a>
          <a v-if="state.wa?.channel_url" :href="state.wa.channel_url" target="_blank" rel="noopener">WhatsApp Channel</a>
          <p v-if="!numbers.length">Hubungi admin lewat halaman Kontak.</p>
        </div>
        <div class="foot-col">
          <h4>Pre-Order</h4>
          <NuxtLink to="/po">Lihat jadwal Next PO</NuxtLink>
          <template v-if="state.settings.instagram_url || state.settings.tiktok_url">
            <h4>Ikuti Kami</h4>
            <a v-if="state.settings.instagram_url" :href="state.settings.instagram_url" target="_blank" rel="noopener">Instagram</a>
            <a v-if="state.settings.tiktok_url" :href="state.settings.tiktok_url" target="_blank" rel="noopener">TikTok</a>
          </template>
        </div>
      </div>
      <div class="wrap foot-base">
        <span>© {{ new Date().getFullYear() }} {{ BRAND.name }} · {{ BRAND.store }}</span>
        <span v-if="state.settings.shipping_info">{{ state.settings.shipping_info }}</span>
      </div>
    </div>
  </footer>
</template>

<script setup lang="ts">
const { numbers, link, state } = useWa()
</script>