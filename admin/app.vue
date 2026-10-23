<template>
  <NuxtLayout>
    <NuxtPage />
    <div class="toasts" aria-live="polite">
      <div v-for="t in list" :key="t.id" class="toast" :class="t.type">{{ t.text }}</div>
    </div>
  </NuxtLayout>
</template>

<script setup lang="ts">
const { list } = useToast()
</script>
