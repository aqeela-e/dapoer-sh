<template>
  <div>
    <div class="bar">
      <div>
        <h1>{{ title }}</h1>
        <p v-if="subtitle" class="lead">{{ subtitle }}</p>
      </div>
      <button class="btn" @click="openForm()">{{ addLabel || 'Tambah' }}</button>
    </div>
    <div class="tools">
      <input v-model="q" type="search" placeholder="Cari" aria-label="Cari" @input="page = 1">
      <select v-for="f in filters" :key="f.key" v-model="fv[f.key]" :aria-label="f.label" @change="page = 1">
        <option value="">{{ f.label }}</option>
        <option v-for="o in filterOptions(f)" :key="o.value" :value="o.value">{{ o.label }}</option>
      </select>
    </div>
    <div class="card">
      <div v-if="loading" class="empty">Memuat data...</div>
      <div v-else-if="!paged.length" class="empty"><strong>{{ rows.length ? 'Tidak ada hasil' : 'Belum ada data' }}</strong>{{ rows.length ? 'Ubah kata kunci atau filter pencarian.' : 'Klik tombol di kanan atas untuk menambahkan data pertama.' }}</div>
      <table v-else>
        <thead>
          <tr>
            <th v-for="c in columns" :key="c.key">{{ c.label }}</th>
            <th>Aksi</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="r in paged" :key="r.id">
            <td v-for="c in columns" :key="c.key">
              <template v-if="c.type === 'image'">
                <img v-if="get(r, c.key)" class="thumb" :class="{ lg: c.tall }" :src="get(r, c.key)" alt="">
                <span v-else class="thumb ph" :class="{ lg: c.tall }" aria-label="Belum ada gambar"><NavIcon name="image" /></span>
              </template>
              <button v-else-if="c.type === 'bool' && c.toggle" type="button" class="sw" :class="{ on: get(r, c.key) }" role="switch" :aria-checked="!!get(r, c.key)" :aria-label="c.label + ': ' + (get(r, c.key) ? 'aktif' : 'nonaktif')" @click="flip(r, c.key)"><i />{{ get(r, c.key) ? c.onLabel || 'Aktif' : c.offLabel || 'Nonaktif' }}</button>
              <span v-else-if="c.type === 'bool'" class="chip" :class="{ on: get(r, c.key) }">{{ get(r, c.key) ? 'Ya' : 'Tidak' }}</span>
              <span v-else-if="c.type === 'badge'" class="chip" :class="c.tones?.[get(r, c.key)]">{{ c.map?.[get(r, c.key)] ?? get(r, c.key) ?? '-' }}</span>
              <span v-else-if="c.type === 'color'" class="chip plain" :style="{ background: get(r, c.key), color: '#fff' }">{{ get(r, c.key) }}</span>
              <template v-else>{{ cell(r, c) }}</template>
            </td>
            <td>
              <div class="actions">
                <template v-if="reorder">
                  <button class="btn sec sm" aria-label="Naik" :disabled="!canMove" @click="move(r, -1)">↑</button>
                  <button class="btn sec sm" aria-label="Turun" :disabled="!canMove" @click="move(r, 1)">↓</button>
                </template>
                <button class="btn sec sm" @click="openForm(r)">Edit</button>
                <button class="btn danger sm" @click="delRow = r">Hapus</button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
      <div v-if="filtered.length > size" class="pager">
        <button class="btn sec sm" :disabled="page <= 1" @click="page--">Sebelumnya</button>
        <span>{{ page }} / {{ pages }}</span>
        <button class="btn sec sm" :disabled="page >= pages" @click="page++">Berikutnya</button>
      </div>
    </div>

    <div v-if="open" class="overlay">
      <form class="modal" novalidate @submit.prevent="save">
        <header>
          <h2>{{ editing ? 'Edit' : 'Tambah' }} {{ title }}</h2>
          <button type="button" class="btn sec sm" @click="open = false">Tutup</button>
        </header>
        <div class="body">
          <div v-for="f in fields" :key="f.key" class="f" :class="{ chk: f.type === 'bool' }">
            <label :for="'f-' + f.key">
              <input v-if="f.type === 'bool'" :id="'f-' + f.key" v-model="form[f.key]" type="checkbox">
              {{ f.label }}<template v-if="f.required"> *</template>
            </label>
            <textarea v-if="f.type === 'textarea'" :id="'f-' + f.key" v-model="form[f.key]" rows="3" />
            <template v-else-if="f.type === 'rich'">
              <RichEditor v-model="form[f.key]" />
              <div v-if="form[f.key]" class="prev"><small class="help">Pratinjau</small><div v-html="form[f.key]" /></div>
            </template>
            <select v-else-if="f.type === 'select'" :id="'f-' + f.key" v-model="form[f.key]">
              <option value="">Pilih</option>
              <option v-for="o in fieldOptions(f)" :key="o.value" :value="o.value">{{ o.label }}</option>
            </select>
            <div v-else-if="f.type === 'image'" class="upl">
              <img v-if="form[f.key]" :src="form[f.key]" alt="Pratinjau gambar">
              <span v-else class="upl-ph"><NavIcon name="image" /></span>
              <div class="upl-side">
                <div class="upl-row">
                  <label class="btn sec sm" :for="'f-' + f.key" style="margin:0;cursor:pointer">{{ form[f.key] ? 'Ganti gambar' : 'Pilih gambar' }}</label>
                  <button v-if="form[f.key]" type="button" class="btn danger sm" @click="form[f.key] = ''">Hapus</button>
                </div>
                <span>JPG, PNG, atau WebP. Maksimal 5 MB.</span>
                <input :id="'f-' + f.key" class="sr" type="file" accept="image/*" @change="upload($event, form, f.key)">
              </div>
            </div>
            <input v-else-if="f.type === 'bool'" v-show="false" type="hidden">
            <input
              v-else
              :id="'f-' + f.key"
              v-model="form[f.key]"
              :type="inputType(f.type)"
              :min="f.min"
              :step="f.type === 'number' ? 'any' : undefined"
              :placeholder="f.placeholder"
            >
            <div v-if="f.help" class="help">{{ f.help }}</div>
            <div v-if="errs[f.key]" class="err" role="alert">{{ errs[f.key] }}</div>
          </div>

          <div v-for="r in relations" :key="r.name" class="f">
            <label>{{ r.label }}</label>
            <div v-for="(row, i) in rel[r.name]" :key="i" class="relrow">
              <template v-for="rf in r.fields" :key="rf.key">
                <label v-if="rf.type === 'bool'" style="font-weight:500;margin:0;display:flex;gap:8px;align-items:center"><input v-model="row[rf.key]" type="checkbox"> {{ rf.label }}</label>
                <div v-else-if="rf.type === 'image'" style="display:flex;gap:10px;align-items:center">
                  <img v-if="row[rf.key]" :src="row[rf.key]" alt="" style="height:48px;width:48px;object-fit:cover;border-radius:8px;border:1px solid var(--line)">
                  <input type="file" accept="image/*" :aria-label="rf.label" @change="upload($event, row, rf.key)">
                </div>
                <input v-else v-model="row[rf.key]" :type="inputType(rf.type)" :placeholder="rf.label" :aria-label="rf.label" step="any">
              </template>
              <button type="button" class="btn danger sm" @click="rel[r.name].splice(i, 1)">Hapus</button>
            </div>
            <button type="button" class="btn sec sm" @click="rel[r.name].push(blank(r))">+ Tambah {{ r.label.toLowerCase() }}</button>
            <div v-if="errs[r.name]" class="err">{{ errs[r.name] }}</div>
          </div>

          <div v-for="l in links" :key="l.name" class="f">
            <label>{{ l.label }}</label>
            <div class="checks">
              <label v-for="o in lnkOpts[l.name]" :key="o.id">
                <input v-model="lnk[l.name]" type="checkbox" :value="o.id"> {{ o.name }}
              </label>
            </div>
          </div>
        </div>
        <footer>
          <button type="button" class="btn sec" @click="open = false">Batal</button>
          <button class="btn" :disabled="saving">{{ saving ? 'Menyimpan...' : 'Simpan' }}</button>
        </footer>
      </form>
    </div>

    <div v-if="delRow" class="overlay">
      <div class="modal sm" role="alertdialog" aria-modal="true">
        <div class="body">
          <h2>Hapus data?</h2>
          <p>Data yang dihapus tidak bisa dikembalikan.</p>
        </div>
        <footer>
          <button class="btn sec" @click="delRow = null">Batal</button>
          <button class="btn danger" @click="remove">Hapus</button>
        </footer>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const props = defineProps<{
  title: string
  table: string
  fields: any[]
  columns: any[]
  select?: string
  orderBy?: { col: string; asc: boolean }
  searchKeys?: string[]
  relations?: any[]
  links?: any[]
  defaults?: any
  subtitle?: string
  addLabel?: string
  fixed?: any
  reorder?: boolean
  filters?: any[]
}>()

const sb = useSb()
const toast = useToast()
const doUpload = useUpload()
const size = 10
const rows = ref<any[]>([])
const loading = ref(true)
const q = ref('')
const page = ref(1)
const fv = reactive<any>({})
const opts = reactive<any>({})
const open = ref(false)
const editing = ref<any>(null)
const form = reactive<any>({})
const errs = reactive<any>({})
const rel = reactive<any>({})
const lnk = reactive<any>({})
const lnkOpts = reactive<any>({})
const saving = ref(false)
const delRow = ref<any>(null)
props.filters?.forEach((f) => (fv[f.key] = ''))

const get = (o: any, p: string) => p.split('.').reduce((a: any, k) => a?.[k], o)
const inputType = (t: string) => (t === 'datetime' ? 'datetime-local' : t === 'url' ? 'url' : t === 'number' ? 'number' : t === 'date' ? 'date' : t === 'color' ? 'color' : 'text')
const blank = (r: any) => Object.fromEntries(r.fields.map((f: any) => [f.key, f.type === 'bool' ? true : f.type === 'number' ? 0 : '']))

const fieldOptions = (f: any) => f.options || opts[f.key] || []
const filterOptions = (f: any) => f.options || opts['filter:' + f.key] || []

const cell = (r: any, c: any) => {
  const v = get(r, c.key)
  if (c.type === 'money') return rupiah(v)
  if (c.type === 'date') return fmtDateTime(v)
  if (c.type === 'html') return String(v || '').replace(/<[^>]*>/g, ' ').slice(0, 90)
  return v ?? '-'
}

const filtered = computed(() => {
  const keys = props.searchKeys || props.columns.map((c) => c.key)
  const s = q.value.toLowerCase()
  return rows.value.filter((r) => {
    if (s && !keys.some((k) => String(get(r, k) ?? '').toLowerCase().includes(s))) return false
    return Object.entries(fv).every(([k, v]) => !v || String(get(r, k)) === v)
  })
})
const pages = computed(() => Math.max(1, Math.ceil(filtered.value.length / size)))
const paged = computed(() => filtered.value.slice((page.value - 1) * size, page.value * size))
const canMove = computed(() => !q.value && !Object.values(fv).some(Boolean))

const load = async () => {
  loading.value = true
  const { data, error } = await sb
    .from(props.table)
    .select(props.select || '*')
    .order(props.orderBy?.col || 'created_at', { ascending: props.orderBy?.asc ?? false })
  if (error) toast.err(error.message)
  rows.value = data || []
  loading.value = false
}

const loadOpts = async () => {
  const jobs: any[] = []
  const add = (key: string, from: any) =>
    jobs.push(
      sb.from(from.table).select('*').order(from.label, { ascending: true }).then(({ data }: any) => {
        opts[key] = (data || []).map((d: any) => ({ value: d[from.value || 'id'], label: d[from.label] }))
      })
    )
  props.fields.forEach((f) => f.optionsFrom && add(f.key, f.optionsFrom))
  props.filters?.forEach((f) => f.optionsFrom && add('filter:' + f.key, f.optionsFrom))
  props.links?.forEach((l) =>
    jobs.push(sb.from(l.source).select('id,name').order('name').then(({ data }: any) => (lnkOpts[l.name] = data || [])))
  )
  await Promise.all(jobs)
}

const openForm = async (row?: any) => {
  editing.value = row || null
  Object.keys(errs).forEach((k) => delete errs[k])
  props.fields.forEach((f) => {
    let v = row ? row[f.key] : props.defaults?.[f.key] ?? (f.type === 'bool' ? false : f.type === 'number' ? 0 : '')
    if (f.type === 'datetime' && v) v = toLocalInput(v)
    form[f.key] = v ?? ''
  })
  for (const r of props.relations || []) {
    rel[r.name] = []
    if (row) {
      const { data } = await sb.from(r.table).select('*').eq(r.fk, row.id).order(r.order || 'sort_order')
      rel[r.name] = (data || []).map((d: any) => Object.fromEntries(r.fields.map((f: any) => [f.key, d[f.key] ?? (f.type === 'bool' ? false : '')])))
    }
  }
  for (const l of props.links || []) {
    lnk[l.name] = []
    if (row) {
      const { data } = await sb.from(l.table).select(l.other).eq(l.fk, row.id)
      lnk[l.name] = (data || []).map((d: any) => d[l.other])
    }
  }
  open.value = true
}

const validate = () => {
  Object.keys(errs).forEach((k) => delete errs[k])
  props.fields.forEach((f) => {
    const v = form[f.key]
    const empty = v === '' || v === null || v === undefined
    if (f.required && empty) errs[f.key] = 'Wajib diisi'
    else if (f.type === 'number' && !empty && Number(v) < (f.min ?? -Infinity)) errs[f.key] = 'Minimal ' + f.min
    else if (f.type === 'url' && v && !/^https?:\/\/.+/i.test(v)) errs[f.key] = 'Gunakan URL yang diawali http:// atau https://'
    else if (f.pattern && v && !new RegExp(f.pattern).test(v)) errs[f.key] = f.patternMsg || 'Format tidak valid'
  })
  for (const r of props.relations || []) {
    const bad = rel[r.name].some((row: any) => r.fields.some((f: any) => f.required && (row[f.key] === '' || row[f.key] === null)))
    if (bad) errs[r.name] = 'Lengkapi kolom yang wajib diisi'
  }
  return !Object.keys(errs).length
}

const save = async () => {
  if (!validate()) return
  saving.value = true
  const payload: any = {}
  props.fields.forEach((f) => {
    let v = form[f.key]
    if (f.slugFrom && !v) v = slugify(String(form[f.slugFrom] || ''))
    if (f.type === 'number') v = v === '' ? null : Number(v)
    else if (f.type === 'datetime') v = v ? new Date(v).toISOString() : null
    else if (v === '') v = null
    payload[f.key] = v
  })
  Object.entries(props.fixed || {}).forEach(([k, v]) => {
    if (payload[k] === null || payload[k] === undefined) payload[k] = v
  })
  const q1 = editing.value
    ? sb.from(props.table).update(payload).eq('id', editing.value.id).select('id').single()
    : sb.from(props.table).insert(payload).select('id').single()
  const { data, error } = await q1
  if (error) {
    saving.value = false
    return toast.err(error.message)
  }
  try {
    for (const r of props.relations || []) {
      const del = await sb.from(r.table).delete().eq(r.fk, data.id)
      if (del.error) throw del.error
      if (rel[r.name].length) {
        const ins = await sb.from(r.table).insert(
          rel[r.name].map((row: any, i: number) => {
            const o: any = { [r.fk]: data.id }
            r.fields.forEach((f: any) => (o[f.key] = f.type === 'number' ? (row[f.key] === '' || row[f.key] === null ? null : Number(row[f.key])) : row[f.key] === '' ? null : row[f.key]))
            if (!r.fields.some((f: any) => f.key === 'sort_order')) o.sort_order = i
            return o
          })
        )
        if (ins.error) throw ins.error
      }
    }
    for (const l of props.links || []) {
      const del = await sb.from(l.table).delete().eq(l.fk, data.id)
      if (del.error) throw del.error
      if (lnk[l.name].length) {
        const ins = await sb.from(l.table).insert(lnk[l.name].map((id: string) => ({ [l.fk]: data.id, [l.other]: id })))
        if (ins.error) throw ins.error
      }
    }
  } catch (e: any) {
    saving.value = false
    return toast.err(e.message)
  }
  saving.value = false
  open.value = false
  toast.ok('Data berhasil disimpan')
  await load()
}

const remove = async () => {
  const { error } = await sb.from(props.table).delete().eq('id', delRow.value.id)
  delRow.value = null
  if (error) return toast.err(error.message)
  toast.ok('Data dihapus')
  await load()
}

const flip = async (r: any, key: string) => {
  const { error } = await sb.from(props.table).update({ [key]: !r[key] }).eq('id', r.id)
  if (error) return toast.err(error.message)
  r[key] = !r[key]
  toast.ok('Status diperbarui')
}

const move = async (r: any, dir: number) => {
  const list = [...rows.value].sort((a, b) => a.sort_order - b.sort_order)
  const i = list.findIndex((x) => x.id === r.id)
  const j = i + dir
  if (j < 0 || j >= list.length) return
  ;[list[i], list[j]] = [list[j], list[i]]
  const jobs = list.map((x, idx) => (x.sort_order !== idx + 1 ? sb.from(props.table).update({ sort_order: idx + 1 }).eq('id', x.id) : null)).filter(Boolean)
  const res = await Promise.all(jobs as any[])
  const failed = res.find((x: any) => x.error)
  if (failed) return toast.err(failed.error.message)
  await load()
}

const upload = async (e: Event, target: any, key: string) => {
  const file = (e.target as HTMLInputElement).files?.[0]
  if (!file) return
  if (file.size > 5 * 1024 * 1024) return toast.err('Ukuran gambar maksimal 5 MB')
  try {
    target[key] = await doUpload(file)
    toast.ok('Gambar terunggah')
  } catch (err: any) {
    toast.err(err.message)
  }
}

onMounted(async () => {
  await Promise.all([load(), loadOpts()])
})
</script>