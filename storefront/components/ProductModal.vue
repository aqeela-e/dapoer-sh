<template>
  <div class="overlay" @click.self="$emit('close')">
    <div ref="box" class="modal pm" role="dialog" aria-modal="true" :aria-label="p.name" tabindex="-1">
      <button class="x" type="button" aria-label="Tutup" @click="$emit('close')"><span /><span /></button>
      <div class="detail">
        <div class="gal">
          <div class="gal-main">
            <img v-if="p.images[img]" :src="p.images[img]" :alt="p.name">
            <LogoArt v-else />
            <div class="badges">
              <span v-for="l in p.labels" :key="l.id" class="badge" :style="{ background: l.color }">{{ l.name }}</span>
            </div>
          </div>
          <div v-if="p.images.length > 1" class="thumbs">
            <button v-for="(u, i) in p.images" :key="u" type="button" :class="{ on: i === img }" :aria-label="'Foto ' + (i + 1)" @click="img = i"><img :src="u" alt=""></button>
          </div>
        </div>
        <div class="body">
          <h2>{{ p.name }}</h2>
          <div class="price big">{{ rupiah(price) }}</div>
          <span class="avail" :class="{ no: !av.ok }">{{ av.text }}<template v-if="av.ok && p.po_status === 'ready'"> · stok {{ stock }}</template></span>
          <p v-if="p.description" class="desc">{{ p.description }}</p>
          <div v-if="p.variants.length" class="opts" role="group" aria-label="Varian">
            <button v-for="v in p.variants" :key="v.id" type="button" :class="{ on: variant?.id === v.id }" :disabled="v.stock <= 0 && p.po_status === 'ready'" @click="variant = v">
              {{ v.name }}
            </button>
          </div>
          <p v-if="p.shipping_estimate" class="meta">Pengiriman: {{ p.shipping_estimate }}</p>
          <p v-if="p.storage_info" class="meta">Penyimpanan: {{ p.storage_info }}</p>
          <p v-if="p.notes" class="meta">{{ p.notes }}</p>
          <template v-if="canOrder">
            <div class="row">
              <a v-for="(n, i) in numbers" :key="n.number" class="btn wa" :class="{ alt: i > 0 }" :href="link(n.number)" target="_blank" rel="noopener">
                <WaIcon />Pesan via {{ n.label }}
              </a>
            </div>
            <p v-if="numbers.length > 1 && state.wa?.fallback_message" class="note">{{ state.wa.fallback_message }}</p>
          </template>
          <p v-else class="note">Produk ini belum bisa dipesan saat ini. Pantau jadwal Next PO.</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const props = defineProps<{ p: any }>()
const emit = defineEmits(['close'])
const { state } = useSite()
const img = ref(0)
const variant = ref<any>(props.p.variants.find((v: any) => v.stock > 0) || props.p.variants[0] || null)
const box = ref<HTMLElement>()
const av = computed(() => availability(props.p))
const price = computed(() => variant.value?.price ?? props.p.price)
const stock = computed(() => (variant.value ? variant.value.stock : props.p.stock))
const canOrder = computed(() => av.value.ok && numbers.value.length > 0 && (props.p.po_status !== 'ready' || stock.value > 0))
const numbers = computed(() => {
  const w = state.value.wa
  if (!w) return []
  return [
    { label: w.label_primary, number: w.number_primary },
    { label: w.label_secondary, number: w.number_secondary }
  ].filter((n) => n.number)
})
const link = (number: string) =>
  waLink(number, state.value.wa.message_template, {
    produk: props.p.name,
    varian: variant.value?.name || '-',
    harga: rupiah(price.value)
  })

const onKey = (e: KeyboardEvent) => {
  if (e.key === 'Escape') emit('close')
}

onMounted(() => {
  box.value?.focus()
  document.body.style.overflow = 'hidden'
  window.addEventListener('keydown', onKey)
})
onBeforeUnmount(() => {
  document.body.style.overflow = ''
  window.removeEventListener('keydown', onKey)
})
</script>