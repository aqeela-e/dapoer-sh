<template>
  <svg class="edge" :class="{ top }" viewBox="0 0 1440 120" preserveAspectRatio="none" aria-hidden="true" focusable="false">
    <path :d="d" :fill="color" />
  </svg>
</template>

<script setup lang="ts">
const props = withDefaults(defineProps<{ color?: string; seed?: number; top?: boolean }>(), { color: 'var(--cream)', seed: 1, top: false })

const rng = (a: number) => () => {
  a |= 0
  a = (a + 0x6d2b79f5) | 0
  let t = Math.imul(a ^ (a >>> 15), 1 | a)
  t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t
  return ((t ^ (t >>> 14)) >>> 0) / 4294967296
}

const d = computed(() => {
  const r = rng(props.seed * 9973)
  const W = 1440
  const H = 120
  let x = -40
  let y = 62 + r() * 12
  let out = `M-40,${H} L-40,${y.toFixed(1)}`
  while (x < W + 40) {
    const w = 100 + r() * 110
    const ny = 58 + r() * 18
    const ry = 22 + r() * 34
    out += ` A${(w / 2).toFixed(1)},${ry.toFixed(1)} 0 0 1 ${(x + w).toFixed(1)},${ny.toFixed(1)}`
    x += w
    y = ny
  }
  return out + ` L${(x).toFixed(1)},${H} Z`
})
</script>