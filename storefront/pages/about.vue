<template>
  <section class="page">
    <div class="page-hero">
      <div class="wrap">
        <p class="tagline sm">{{ BRAND.store }}</p>
        <h1 class="h">Cerita Gabin</h1>
      </div>
    </div>
    <div class="sec story flat last">
      <CloudEdge color="var(--pink)" :seed="14" />
      <div class="wrap story-grid">
        <div class="story-art" v-reveal>
          <i class="story-blob" />
          <div class="shot s1" :class="{ empty: !images[0] }"><img v-if="images[0]" :src="images[0]" alt="Produk Gabin Ice Cream" loading="lazy"><LogoArt v-else /></div>
        </div>
        <div v-reveal="120">
          <div v-if="state.settings.about_story" class="rich story-text" v-html="sanitize(state.settings.about_story)" />
          <p v-else class="empty">Cerita brand akan segera diperbarui.</p>
          <div v-if="state.settings.storage_info" class="note">Tips penyimpanan: {{ state.settings.storage_info }}</div>
          <div class="row"><NuxtLink to="/shop" class="btn">Lihat Semua Rasa</NuxtLink></div>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
const { state } = useSite()
const { images } = useShowcase()
</script>