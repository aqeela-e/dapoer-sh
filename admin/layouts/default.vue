<template>
  <div class="shell">
    <div v-if="open" class="scrim" @click="open = false" />
    <aside class="side" :class="{ open }" aria-label="Navigasi utama">
      <div class="brand">
        <span class="brand-mark">G</span>
        <div><strong>Gabin Ice Cream</strong><small>Panel Admin</small></div>
      </div>
      <nav @click="open = false">
        <template v-for="g in groups" :key="g.title">
          <div class="nav-grp">{{ g.title }}</div>
          <NuxtLink v-for="i in g.items" :key="i.to" :to="i.to"><NavIcon :name="i.icon" />{{ i.label }}</NuxtLink>
        </template>
      </nav>
      <div class="side-foot">
        <div class="side-user">{{ email }}</div>
        <button class="out" type="button" @click="logout"><NavIcon name="out" />Keluar</button>
      </div>
    </aside>
    <div class="main">
      <div class="topbar">
        <button class="icon-btn" type="button" aria-label="Buka menu" @click="open = true"><NavIcon name="menu" /></button>
        <strong>Gabin Admin</strong>
      </div>
      <main class="page"><slot /></main>
    </div>
  </div>
</template>

<script setup lang="ts">
const sb = useSb()
const open = ref(false)
const email = ref('')
const groups = [
  { title: 'Ringkasan', items: [{ to: '/', label: 'Dashboard', icon: 'dashboard' }] },
  {
    title: 'Katalog',
    items: [
      { to: '/products', label: 'Produk', icon: 'box' },
      { to: '/categories', label: 'Kategori', icon: 'tag' },
      { to: '/labels', label: 'Label produk', icon: 'label' }
    ]
  },
  {
    title: 'Storefront',
    items: [
      { to: '/announcements', label: 'Next PO', icon: 'calendar' },
      { to: '/banners', label: 'Banner hero', icon: 'image' },
      { to: '/testimonials', label: 'Testimoni', icon: 'quote' },
      { to: '/faq', label: 'FAQ chatbot', icon: 'chat' },
      { to: '/faq-categories', label: 'Kategori FAQ', icon: 'list' },
      { to: '/content', label: 'Konten website', icon: 'file' },
      { to: '/whatsapp', label: 'WhatsApp', icon: 'phone' }
    ]
  },
  {
    title: 'Operasional',
    items: [
      { to: '/transactions', label: 'Transaksi', icon: 'receipt' },
      { to: '/stock', label: 'Stok', icon: 'layers' },
      { to: '/reports', label: 'Laporan', icon: 'chart' }
    ]
  },
  {
    title: 'Sistem',
    items: [
      { to: '/logs', label: 'Aktivitas', icon: 'activity' },
      { to: '/profile', label: 'Profil', icon: 'user' }
    ]
  }
]
const logout = async () => {
  await sb.auth.signOut()
  await navigateTo('/login')
}
onMounted(async () => {
  const { data } = await sb.auth.getUser()
  email.value = data.user?.email || ''
})
</script>