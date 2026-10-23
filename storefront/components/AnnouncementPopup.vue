<template>
  <Transition name="pop">
    <div v-if="view" class="overlay popo" @click.self="close">
      <div ref="box" class="popcard" :class="{ plain: !view.isPo }" role="dialog" aria-modal="true" :aria-label="view.title" tabindex="-1">
        <button class="x" type="button" aria-label="Tutup" @click="close"><span /><span /></button>
        <div class="pop-art" aria-hidden="true">
          <i class="pop-blob b1" /><i class="pop-blob b2" />
          <img v-if="view.image" class="pop-img" :src="view.image" alt="">
          <template v-else>
            <div class="pop-shot s1"><img v-if="images[0]" :src="images[0]" alt=""><LogoArt v-else /></div>
            <div class="pop-shot s2"><img v-if="images[1]" :src="images[1]" alt=""><LogoArt v-else /></div>
          </template>
        </div>
        <div class="pop-body">
          <span v-if="view.isPo" class="pill"><i class="dot" :class="{ off: view.status === 'closed' }" />{{ view.statusText }}</span>
          <h2>{{ view.title }}</h2>
          <p v-if="view.isPo" class="pop-date">{{ view.dateText }}</p>
          <p v-if="view.countdown" class="pop-count">{{ view.countdown }}</p>
          <div v-if="view.body" class="rich" v-html="sanitize(view.body)" />
          <p v-if="view.delivery" class="meta">Estimasi pengiriman: {{ view.delivery }}</p>
          <p v-if="view.note" class="meta">{{ view.note }}</p>
          <a v-if="view.external" class="btn" :href="view.cta.url" target="_blank" rel="noopener" @click="close">{{ view.cta.label }}</a>
          <NuxtLink v-else class="btn" :to="view.cta.url" @click="close">{{ view.cta.label }}</NuxtLink>
          <button type="button" class="later" @click="close">Nanti saja</button>
        </div>
      </div>
    </div>
  </Transition>
</template>

<script setup lang="ts">
const sb = useSb()
const { images } = useShowcase()
const view = ref<any>(null)
const box = ref<HTMLElement>()

const fmt = (d?: string) => (d ? new Date(d + 'T00:00:00').toLocaleDateString('id-ID', { day: 'numeric', month: 'long' }) : '')
const dismissed = (id: string) => {
  const v = Number(localStorage.getItem('gabin-pop-' + id) || 0)
  return v > 0 && Date.now() - v < POPUP_TTL_MS
}
const dayDiff = (d: string) => Math.ceil((new Date(d + 'T00:00:00').getTime() - new Date().setHours(0, 0, 0, 0)) / 86400000)

const poView = (a: any | null) => {
  if (!a) {
    return { id: 'fallback', isPo: true, title: PO_FALLBACK.heading, dateText: PO_FALLBACK.dateText, statusText: PO_FALLBACK.statusText, status: 'soon', note: PO_FALLBACK.note, cta: { url: '/shop', label: PO_FALLBACK.ctaOpen } }
  }
  const open = a.po_open !== false
  const range = a.po_start ? (a.po_end && a.po_end !== a.po_start ? `${fmt(a.po_start)} - ${fmt(a.po_end)}` : fmt(a.po_start)) : PO_FALLBACK.dateText
  const diff = a.po_start ? dayDiff(a.po_start) : null
  let countdown = ''
  if (open && diff !== null && diff > 0) countdown = diff === 1 ? 'Dibuka besok' : `Dibuka ${diff} hari lagi`
  if (open && diff !== null && diff <= 0) countdown = 'Sedang berlangsung'
  return {
    id: a.id,
    isPo: true,
    title: a.title,
    dateText: range,
    statusText: open ? 'PO dibuka' : 'PO ditutup',
    status: open ? 'open' : 'closed',
    countdown,
    body: a.body,
    delivery: a.delivery_estimate,
    cta: { url: a.cta_url || (open ? '/shop' : '/po'), label: a.cta_label || (open ? PO_FALLBACK.ctaOpen : PO_FALLBACK.ctaClosed) }
  }
}

const plainView = (a: any) => ({ id: a.id, isPo: false, title: a.title, body: a.body, image: a.image_url, cta: { url: a.cta_url || '/shop', label: a.cta_label || 'Selengkapnya' } })

const close = () => {
  if (view.value) localStorage.setItem('gabin-pop-' + view.value.id, String(Date.now()))
  view.value = null
  document.body.style.overflow = ''
}

const onKey = (e: KeyboardEvent) => {
  if (e.key === 'Escape' && view.value) close()
}

onMounted(async () => {
  window.addEventListener('keydown', onKey)
  const now = new Date().toISOString()
  const live = (q: any) => q.eq('is_active', true).lte('starts_at', now).or(`ends_at.is.null,ends_at.gte.${now}`).order('starts_at', { ascending: false })
  const [pop, po] = await Promise.all([
    live(sb.from('announcements').select('*').eq('placement', 'popup')),
    live(sb.from('announcements').select('*').eq('is_po', true)).limit(1)
  ])
  const popups = (pop.data || []) as any[]
  const poRow = po.data?.[0] || null
  const poPopup = popups.find((x) => x.is_po)
  const candidate = popups.find((x) => !x.is_po && !dismissed(x.id))
  let next: any = null
  if (poPopup) next = dismissed(poPopup.id) ? null : poView(poPopup)
  else if (candidate) next = plainView(candidate)
  else if (!dismissed(poRow?.id || 'fallback')) next = poView(poRow)
  if (!next) return
  next.external = /^https?:/i.test(next.cta.url)
  setTimeout(() => {
    view.value = next
    document.body.style.overflow = 'hidden'
    nextTick(() => box.value?.focus())
  }, 1400)
})

onBeforeUnmount(() => {
  window.removeEventListener('keydown', onKey)
  document.body.style.overflow = ''
})
</script>