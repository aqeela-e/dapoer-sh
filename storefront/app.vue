<template>
  <div class="shell">
    <SiteHeader />
    <main>
      <NuxtPage />
    </main>
    <SiteFooter />
    <ScrollRocket />
    <ChatLauncher />
    <AnnouncementPopup />
  </div>
</template>

<script setup lang="ts">
const { load } = useSite()
onMounted(load)
</script>