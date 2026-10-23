<template>
  <header class="top">
    <div class="wrap nav">
      <NuxtLink to="/" class="brand" aria-label="Gabin Ice Cream, beranda" @click="open = false">
        <img class="brand-logo" src="/images/logo.png" :alt="BRAND.store" width="62" height="37">
        <span class="brand-name">Gabin<small>Ice Cream</small></span>
      </NuxtLink>
      <button class="burger" type="button" :aria-expanded="open" aria-controls="main-nav" aria-label="Menu" @click="open = !open">
        <span /><span /><span />
      </button>
      <nav id="main-nav" class="links" :class="{ open }" @click="open = false">
        <NuxtLink to="/">Home</NuxtLink>
        <NuxtLink to="/shop">Shop</NuxtLink>
        <NuxtLink to="/po">Next PO</NuxtLink>
        <NuxtLink to="/contact" class="btn small">Kontak</NuxtLink>
      </nav>
    </div>
  </header>
</template>

<script setup lang="ts">
const open = ref(false)
</script>