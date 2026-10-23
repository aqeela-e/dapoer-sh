<template>
  <div v-if="enabled" ref="stage" class="rocket-stage" aria-hidden="true">
    <div ref="rocket" class="rocket">
      <div ref="tilt" class="rocket-tilt">
        <svg class="rocket-svg" viewBox="0 0 64 128" focusable="false">
          <g class="flame">
            <path d="M24 96 C22 112 28 122 32 128 C36 122 42 112 40 96 Z" fill="#F8F7BA" stroke="#3A2E4F" stroke-width="3" stroke-linejoin="round" />
            <path d="M28 98 C27 108 30 114 32 118 C34 114 37 108 36 98 Z" fill="#F5D2D2" />
          </g>
          <path d="M16 64 L3 94 L19 86 Z" fill="#6FA9BF" stroke="#3A2E4F" stroke-width="3" stroke-linejoin="round" />
          <path d="M48 64 L61 94 L45 86 Z" fill="#6FA9BF" stroke="#3A2E4F" stroke-width="3" stroke-linejoin="round" />
          <path d="M32 4 C47 22 51 52 49 88 L15 88 C13 52 17 22 32 4 Z" fill="#FFFDF7" stroke="#3A2E4F" stroke-width="3" stroke-linejoin="round" />
          <path d="M32 4 C38 11 42 19 44 28 L20 28 C22 19 26 11 32 4 Z" fill="#E9A8A8" stroke="#3A2E4F" stroke-width="3" stroke-linejoin="round" />
          <circle cx="32" cy="52" r="10" fill="#A3CCDA" stroke="#3A2E4F" stroke-width="3" />
          <circle cx="29" cy="49" r="2.6" fill="#fff" />
          <rect x="21" y="88" width="22" height="9" rx="3" fill="#8CC79A" stroke="#3A2E4F" stroke-width="3" stroke-linejoin="round" />
        </svg>
      </div>
    </div>
    <span v-for="n in POOL" :key="n" :ref="(el) => setPuff(el, n - 1)" class="puff" />
  </div>
</template>

<script setup lang="ts">
const POOL = 10
const COLORS = ['#ffffff', '#F5D2D2', '#F8F7BA', '#BDE3C3', '#A3CCDA']
const enabled = ref(false)
const stage = ref<HTMLElement>()
const rocket = ref<HTMLElement>()
const tilt = ref<HTMLElement>()
const puffs: HTMLElement[] = []
const setPuff = (el: any, i: number) => {
  if (el) puffs[i] = el
}

let raf = 0
let y = 0
let x = 0
let lastScroll = 0
let dir = 1
let lastPuff = 0
let puffIdx = 0
let vh = 0
let size = 64

const measure = () => {
  vh = window.innerHeight
  size = window.innerWidth < 640 ? 34 : 50
  rocket.value?.style.setProperty('--rs', size + 'px')
}

const progress = () => {
  const max = document.documentElement.scrollHeight - vh
  return max > 0 ? Math.min(1, Math.max(0, window.scrollY / max)) : 0
}

const emit = (px: number, py: number, now: number, speed: number) => {
  if (now - lastPuff < 110 || speed < 0.6) return
  lastPuff = now
  const el = puffs[puffIdx++ % POOL]
  if (!el) return
  const s = 14 + Math.random() * 16
  el.style.width = el.style.height = s + 'px'
  el.style.left = px - s / 2 + 'px'
  el.style.top = py - s / 2 + 'px'
  el.style.background = COLORS[(Math.random() * COLORS.length) | 0]
  el.animate(
    [
      { opacity: 0.95, transform: 'translate(0,0) scale(0.5)' },
      { opacity: 0, transform: `translate(${(Math.random() - 0.5) * 26}px,${-dir * 34}px) scale(1.7)` }
    ],
    { duration: 950, easing: 'cubic-bezier(.2,.7,.3,1)', fill: 'forwards' }
  )
}

const tick = (now: number) => {
  const p = progress()
  const targetY = vh * 0.16 + p * vh * 0.62
  const targetX = Math.sin(p * Math.PI * 6) * 14
  const sy = window.scrollY
  const delta = sy - lastScroll
  if (Math.abs(delta) > 0.5) dir = delta > 0 ? 1 : -1
  lastScroll = sy
  const prevY = y
  y += (targetY - y) * 0.1
  x += (targetX - x) * 0.08
  const speed = Math.abs(y - prevY)
  if (rocket.value) rocket.value.style.transform = `translate3d(${x}px,${y}px,0)`
  if (tilt.value) tilt.value.style.transform = `rotate(${dir > 0 ? 180 : 0}deg)`
  if (rocket.value) {
    const r = rocket.value.getBoundingClientRect()
    emit(r.left + r.width / 2, dir > 0 ? r.top + size * 0.15 : r.bottom - size * 0.15, now, speed)
  }
  raf = requestAnimationFrame(tick)
}

onMounted(() => {
  const mq = window.matchMedia('(prefers-reduced-motion: reduce)')
  enabled.value = !mq.matches
  if (!enabled.value) return
  nextTick(() => {
    measure()
    lastScroll = window.scrollY
    y = vh * 0.16 + progress() * vh * 0.62
    window.addEventListener('resize', measure, { passive: true })
    raf = requestAnimationFrame(tick)
  })
})

onBeforeUnmount(() => {
  cancelAnimationFrame(raf)
  window.removeEventListener('resize', measure)
})
</script>