<template>
  <button class="pc" type="button" @click="$emit('open', p)">
    <span class="pc-img">
      <img v-if="p.images[0]" :src="p.images[0]" :alt="p.name" loading="lazy" decoding="async">
      <LogoArt v-else />
      <span v-if="p.labels.length" class="pc-badges">
        <span v-for="l in p.labels" :key="l.id" class="pc-badge" :style="{ background: l.color }">{{ l.name }}</span>
      </span>
      <span v-if="status" class="pc-status">{{ status }}</span>
    </span>
    <span class="pc-body">
      <span class="pc-name">{{ p.name }}</span>
      <span class="pc-desc">{{ p.description }}</span>
      <span class="pc-meta">
        <span class="pc-price">{{ p.variants.length > 1 ? 'Mulai ' : '' }}{{ rupiah(p.minPrice) }}</span>
        <span v-if="p.historical_sold > 0" class="pc-sold">{{ soldText(p.historical_sold) }}</span>
      </span>
    </span>
  </button>
</template>

<script setup lang="ts">
const props = defineProps<{ p: any }>()
defineEmits(['open'])
const status = computed(() => {
  const a = availability(props.p)
  return a.text === 'Ready Stock' ? '' : a.text
})
</script>