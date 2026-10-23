<template>
  <div>
    <div class="bar">
      <div>
        <h1>Konten website</h1>
        <p class="lead">Teks yang tampil di beranda, kontak, dan footer storefront.</p>
      </div>
    </div>
    <form class="form-wrap" novalidate @submit.prevent="save">
      <section v-for="g in groups" :key="g.title" class="card section">
        <div class="card-head">
          <h2>{{ g.title }}</h2>
          <p>{{ g.desc }}</p>
        </div>
        <div class="body-pad">
          <div v-for="f in g.fields" :key="f.key" class="f">
            <label :for="f.key">{{ f.label }}</label>
            <RichEditor v-if="f.type === 'rich'" v-model="form[f.key]" />
            <textarea v-else-if="f.type === 'textarea'" :id="f.key" v-model="form[f.key]" rows="3" />
            <input v-else :id="f.key" v-model="form[f.key]" type="text" :placeholder="f.placeholder">
            <div v-if="f.help" class="help">{{ f.help }}</div>
            <div v-if="errs[f.key]" class="err" role="alert">{{ errs[f.key] }}</div>
          </div>
        </div>
      </section>
      <div><button class="btn" :disabled="saving">{{ saving ? 'Menyimpan...' : 'Simpan perubahan' }}</button></div>
    </form>
  </div>
</template>

<script setup lang="ts">
const sb = useSb()
const toast = useToast()
const saving = ref(false)
const errs = reactive<any>({})
const groups = [
  {
    title: 'Beranda',
    desc: 'Bagian hero dan cerita brand di halaman utama.',
    fields: [
      { key: 'tagline', label: 'Tagline', type: 'text', placeholder: 'Handmade dengan cinta', help: 'Tampil dengan huruf tulisan tangan di hero dan footer.' },
      { key: 'hero_intro', label: 'Teks pengantar hero', type: 'textarea', help: 'Dipakai jika banner hero tidak punya teks pengantar.' },
      { key: 'about_story', label: 'Cerita brand', type: 'rich', help: 'Tampil di bagian "Cerita Gabin" pada beranda. Kosongkan untuk menyembunyikan bagian ini.' }
    ]
  },
  {
    title: 'Pengiriman dan sosial media',
    desc: 'Tampil di halaman Kontak dan footer.',
    fields: [
      { key: 'shipping_info', label: 'Informasi pengiriman', type: 'textarea' },
      { key: 'instagram_url', label: 'Tautan Instagram', type: 'text', placeholder: 'https://instagram.com/...' },
      { key: 'tiktok_url', label: 'Tautan TikTok', type: 'text', placeholder: 'https://tiktok.com/@...' }
    ]
  }
]
const fields = groups.flatMap((g) => g.fields)
const form = reactive<any>(Object.fromEntries(fields.map((f) => [f.key, ''])))

const save = async () => {
  Object.keys(errs).forEach((k) => delete errs[k])
  ;['instagram_url', 'tiktok_url'].forEach((k) => {
    if (form[k] && !/^https?:\/\/.+/i.test(form[k])) errs[k] = 'Gunakan URL yang diawali http(s)://'
  })
  if (Object.keys(errs).length) return
  saving.value = true
  const { error } = await sb.from('site_settings').upsert(fields.map((f) => ({ key: f.key, value: form[f.key], updated_at: new Date().toISOString() })))
  saving.value = false
  error ? toast.err(error.message) : toast.ok('Konten website disimpan')
}

onMounted(async () => {
  const { data } = await sb.from('site_settings').select('*')
  ;(data || []).forEach((r: any) => r.key in form && (form[r.key] = r.value ?? ''))
})
</script>