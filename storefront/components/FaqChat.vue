<template>
  <div class="cb">
    <div class="cb-head">
      <span class="cb-ava" aria-hidden="true"><img src="/images/logo.png" alt="" width="40" height="24"></span>
      <div>
        <strong>Asisten Gabin</strong>
        <small><i class="dot" />Siap menjawab pertanyaanmu</small>
      </div>
    </div>

    <div ref="feed" class="cb-feed" role="log" aria-live="polite" aria-label="Percakapan FAQ">
      <div v-for="m in msgs" :key="m.id" class="cb-msg" :class="m.from">
        <div class="cb-bubble">
          <div v-if="m.html" class="rich" v-html="sanitize(m.html)" />
          <template v-else>{{ m.text }}</template>
          <div v-if="m.wa" class="cb-bwa">
            <a v-for="(n, i) in numbers" :key="n.key" class="btn wa small" :class="{ alt: i > 0 }" :href="askLink(n.number, m.wa)" target="_blank" rel="noopener"><WaIcon />Tanya {{ n.label }}</a>
          </div>
        </div>
      </div>
      <div v-if="typing" class="cb-msg bot"><div class="cb-bubble cb-typing" aria-label="Asisten sedang mengetik"><i /><i /><i /></div></div>
    </div>

    <div class="cb-quick" aria-label="Pertanyaan cepat">
      <button v-for="q in quick" :key="q.key" type="button" :disabled="typing" @click="q.run()">{{ q.label }}</button>
    </div>

    <form class="cb-form" @submit.prevent="send">
      <input v-model="draft" type="text" maxlength="160" placeholder="Ketik pertanyaan" aria-label="Pertanyaan" :disabled="loading">
      <button class="btn small" type="submit" :disabled="!draft.trim() || typing">Kirim</button>
    </form>
  </div>
</template>

<script setup lang="ts">
const sb = useSb()
const { numbers, askLink } = useWa()

const loading = ref(true)
const faqs = ref<any[]>([])
const cats = ref<any[]>([])
const msgs = ref<any[]>([])
const quick = ref<any[]>([])
const typing = ref(false)
const draft = ref('')
const feed = ref<HTMLElement>()
let uid = 0

const STOP = new Set(['yang', 'dan', 'di', 'ke', 'apa', 'apakah', 'bagaimana', 'gimana', 'kah', 'ya', 'itu', 'ini', 'untuk', 'dengan', 'saya', 'aku', 'kak', 'bisa', 'adalah', 'dari', 'atau', 'kapan', 'dimana', 'mau', 'ada', 'nya', 'sih', 'dong', 'deh'])
const tokens = (s: string) => (s || '').toLowerCase().replace(/<[^>]+>/g, ' ').split(/[^a-z0-9]+/).filter((t) => t.length > 1 && !STOP.has(t))
const hit = (a: string, b: string) => a === b || (a.length >= 4 && b.length >= 4 && (a.startsWith(b) || b.startsWith(a)))

const rank = (text: string) => {
  const q = tokens(text)
  if (!q.length) return []
  return faqs.value
    .map((f) => {
      const tq = tokens(f.question)
      const ta = tokens(f.answer)
      let score = 0
      q.forEach((t) => {
        if (tq.some((x) => hit(x, t))) score += 3
        else if (ta.some((x) => hit(x, t))) score += 1
      })
      return { f, score: score / q.length }
    })
    .filter((r) => r.score >= 1)
    .sort((a, b) => b.score - a.score)
}

const scroll = async () => {
  await nextTick()
  if (feed.value) feed.value.scrollTo({ top: feed.value.scrollHeight, behavior: 'smooth' })
}
const push = (m: any) => {
  msgs.value.push({ id: ++uid, ...m })
  scroll()
}
const botSay = (m: any, delay = 650) =>
  new Promise<void>((res) => {
    typing.value = true
    scroll()
    setTimeout(() => {
      typing.value = false
      push({ from: 'bot', ...m })
      res()
    }, delay)
  })

const showHome = () => {
  const home = faqs.value.filter((f) => f.show_on_home)
  const base = (home.length ? home : faqs.value).slice(0, 4)
  quick.value = [
    ...base.map((f) => ({ key: 'f' + f.id, label: f.question, run: () => ask(f) })),
    ...(cats.value.length > 1 ? cats.value.slice(0, 6).map((c) => ({ key: 'c' + c.id, label: c.name, run: () => openCat(c) })) : [])
  ]
}

const showAfter = (related: any[]) => {
  quick.value = [
    ...related.map((f) => ({ key: 'r' + f.id, label: f.question, run: () => ask(f) })),
    { key: 'more', label: 'Pertanyaan lain', run: () => botSay({ text: 'Tentu, pilih pertanyaan di bawah atau ketik sendiri ya.' }).then(showHome) }
  ]
}

const ask = async (f: any) => {
  push({ from: 'me', text: f.question })
  const related = faqs.value.filter((x) => x.id !== f.id && x.category_id === f.category_id).slice(0, 2)
  await botSay({ html: f.answer }, 600 + Math.min(600, (f.answer || '').length * 2))
  showAfter(related)
}

const openCat = async (c: any) => {
  push({ from: 'me', text: c.name })
  const list = faqs.value.filter((f) => f.category_id === c.id)
  if (!list.length) {
    await botSay({ text: 'Belum ada pertanyaan di kategori ini.' })
    showHome()
    return
  }
  await botSay({ text: 'Ini pertanyaan yang sering muncul di kategori tersebut:' })
  quick.value = [...list.map((f) => ({ key: 'f' + f.id, label: f.question, run: () => ask(f) })), { key: 'back', label: 'Kembali', run: showHome }]
}

const send = async () => {
  const text = draft.value.trim()
  if (!text || typing.value) return
  draft.value = ''
  push({ from: 'me', text })
  const found = rank(text)
  if (found.length) {
    await botSay({ html: found[0].f.answer })
    showAfter(found.slice(1, 3).map((r) => r.f))
  } else {
    await botSay({ text: 'Aku belum menemukan jawaban untuk itu di daftar FAQ. Kamu bisa tanyakan langsung ke admin lewat WhatsApp, pertanyaanmu sudah kami siapkan di pesannya.', wa: text })
    showHome()
  }
}

onMounted(async () => {
  const [f, c] = await Promise.all([
    sb.from('faqs').select('*').eq('is_active', true).order('sort_order'),
    sb.from('faq_categories').select('*').eq('is_active', true).order('sort_order')
  ])
  faqs.value = f.data || []
  cats.value = c.data || []
  loading.value = false
  if (!faqs.value.length) {
    push({ from: 'bot', text: 'Halo! FAQ belum tersedia saat ini, tapi admin siap membantu lewat WhatsApp.', wa: 'Halo kak, aku mau bertanya soal Gabin Ice Cream.' })
    return
  }
  await botSay({ text: 'Halo! Aku asisten Gabin. Pilih pertanyaan di bawah atau ketik sendiri, nanti kucarikan jawabannya.' }, 500)
  showHome()
})
</script>

<style>
.cb{display:flex;flex-direction:column;flex:1;min-height:0;background:#fff}
.cb-head{display:flex;align-items:center;gap:10px;padding:12px 56px 12px 16px;background:var(--yellow);border-bottom:3px solid var(--ink);flex:none}
.cb-ava{width:42px;height:42px;border-radius:50%;background:#fff;border:2.5px solid var(--ink);display:grid;place-items:center;flex:none;overflow:hidden}
.cb-ava img{width:30px;height:auto}
.cb-head strong{display:block;font:600 1rem var(--f-display);line-height:1.25}
.cb-head small{display:flex;align-items:center;gap:6px;font-size:.78rem;color:var(--muted);line-height:1.3}
.cb-feed{flex:1;min-height:0;overflow-y:auto;overscroll-behavior:contain;padding:14px;display:flex;flex-direction:column;gap:10px;background:var(--cream)}
.cb-msg{display:flex}
.cb-msg.me{justify-content:flex-end}
.cb-bubble{max-width:90%;padding:9px 13px;border-radius:18px 18px 18px 5px;background:#fff;border:2.5px solid var(--ink);font-size:.95rem;line-height:1.45;overflow-wrap:anywhere;animation:cbBub .35s var(--ease) both}
.cb-msg.me .cb-bubble{background:var(--pink);border-radius:18px 18px 5px 18px}
.cb-bubble .rich{margin-top:0}
.cb-bwa{display:flex;flex-direction:column;align-items:flex-start;gap:8px;margin-top:10px}
.cb-typing{display:flex;gap:5px;padding:12px 16px}
.cb-typing i{width:8px;height:8px;border-radius:50%;background:var(--ink);animation:cbBlink 1.1s infinite}
.cb-typing i:nth-child(2){animation-delay:.18s}
.cb-typing i:nth-child(3){animation-delay:.36s}
.cb-quick{flex:none;display:flex;flex-wrap:wrap;gap:6px;padding:10px 14px;max-height:104px;overflow-y:auto;background:var(--cream);border-top:2px dashed rgba(58,46,79,.25)}
.cb-quick button{border:2px solid var(--ink);background:#fff;border-radius:999px;padding:5px 12px;font:500 .85rem var(--f-body);line-height:1.3;cursor:pointer;color:var(--ink);text-align:left;transition:transform .2s var(--ease),background .2s}
.cb-quick button:hover:not(:disabled){background:var(--yellow);transform:translateY(-2px)}
.cb-quick button:disabled{opacity:.5;cursor:wait}
.cb-form{flex:none;display:flex;gap:8px;padding:10px 14px 12px;background:var(--cream)}
.cb-form input{flex:1;min-width:0;font:inherit;font-size:.92rem;padding:9px 14px;border-radius:999px;border:2.5px solid var(--ink);background:#fff;color:var(--ink)}
.cb-form .btn{flex:none;padding:8px 16px}
@keyframes cbBub{from{opacity:0;transform:translateY(8px) scale(.97)}}
@keyframes cbBlink{0%,60%,100%{opacity:.25;transform:none}30%{opacity:1;transform:translateY(-4px)}}
@media (prefers-reduced-motion:reduce){.cb-bubble,.cb-typing i{animation:none}}
</style>