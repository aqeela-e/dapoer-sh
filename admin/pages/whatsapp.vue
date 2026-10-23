<template>
  <div>
    <div class="bar">
      <div>
        <h1>WhatsApp</h1>
        <p class="lead">Nomor admin dan pesan otomatis untuk tombol pemesanan, chatbot, dan halaman Kontak.</p>
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
            <textarea v-if="f.type === 'textarea'" :id="f.key" v-model="form[f.key]" rows="3" />
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
const form = reactive<any>({ label_primary: '', number_primary: '', label_secondary: '', number_secondary: '', channel_url: '', message_template: '', fallback_message: '' })
const errs = reactive<any>({})
const groups = [
  {
    title: 'Admin utama',
    desc: 'Dipakai untuk pemesanan produk. Tombol ini tampil pertama.',
    fields: [
      { key: 'label_primary', label: 'Nama tampilan', placeholder: 'Admin Gabin 1' },
      { key: 'number_primary', label: 'Nomor WhatsApp', placeholder: '6281234567890', help: 'Format internasional tanpa tanda +, contoh 6281234567890.' }
    ]
  },
  {
    title: 'Admin alternatif',
    desc: 'Opsional. Tampil sebagai pilihan kedua, misalnya untuk bantuan atau saat admin utama belum membalas.',
    fields: [
      { key: 'label_secondary', label: 'Nama tampilan', placeholder: 'Admin Gabin 2' },
      { key: 'number_secondary', label: 'Nomor WhatsApp', placeholder: '6281234567891' },
      { key: 'fallback_message', label: 'Pesan di bawah tombol admin', type: 'textarea', help: 'Tampil di chatbot, popup produk, dan halaman Kontak saat ada dua admin.' }
    ]
  },
  {
    title: 'Channel dan pesan pesanan',
    desc: 'Pesan otomatis yang terisi ketika pelanggan menekan tombol pesan pada produk.',
    fields: [
      { key: 'channel_url', label: 'URL WhatsApp Channel', placeholder: 'https://whatsapp.com/channel/...' },
      { key: 'message_template', label: 'Template pesan produk', type: 'textarea', help: 'Gunakan {produk}, {varian}, dan {harga}. Contoh: Halo kak, aku mau pesan {produk} varian {varian} harga {harga}.' }
    ]
  }
]

const validate = () => {
  Object.keys(errs).forEach((k) => delete errs[k])
  ;['number_primary', 'number_secondary'].forEach((k) => {
    if (form[k] && !/^[1-9]\d{8,14}$/.test(form[k])) errs[k] = 'Nomor tidak valid. Gunakan format 628xxxxxxxxxx'
  })
  if (!form.number_primary) errs.number_primary = 'Nomor utama wajib diisi'
  if (form.channel_url && !/^https:\/\/(www\.)?whatsapp\.com\/channel\/.+/i.test(form.channel_url)) errs.channel_url = 'Gunakan tautan channel yang diawali https://whatsapp.com/channel/'
  if (!form.message_template.trim()) errs.message_template = 'Template wajib diisi'
  return !Object.keys(errs).length
}

const save = async () => {
  if (!validate()) return
  saving.value = true
  const { error } = await sb.from('whatsapp_settings').upsert({ id: 1, ...form, channel_url: form.channel_url || null })
  saving.value = false
  error ? toast.err(error.message) : toast.ok('Pengaturan WhatsApp disimpan')
}

onMounted(async () => {
  const { data } = await sb.from('whatsapp_settings').select('*').eq('id', 1).maybeSingle()
  if (data) Object.keys(form).forEach((k) => (form[k] = data[k] ?? ''))
})
</script>