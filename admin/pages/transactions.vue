<template>
  <div>
    <div class="bar">
      <h1>Transaksi WhatsApp</h1>
      <button class="btn" @click="openForm()">Catat Transaksi</button>
    </div>
    <div class="tools">
      <input v-model="q" type="search" placeholder="Cari kode atau pelanggan" aria-label="Cari">
      <select v-model="fstatus" aria-label="Filter status">
        <option value="">Semua status</option>
        <option v-for="s in STATUSES" :key="s" :value="s">{{ s }}</option>
      </select>
    </div>
    <div class="card">
      <div v-if="loading" class="empty">Memuat transaksi...</div>
      <div v-else-if="!paged.length" class="empty">Belum ada transaksi. Catat pesanan WhatsApp yang sudah dikonfirmasi.</div>
      <table v-else>
        <thead><tr><th>Kode</th><th>Tanggal</th><th>Pelanggan</th><th>Item</th><th>Total</th><th>Status</th><th>Aksi</th></tr></thead>
        <tbody>
          <tr v-for="r in paged" :key="r.id">
            <td>{{ r.code }}</td>
            <td>{{ r.trx_date }}</td>
            <td>{{ r.customer_name }}</td>
            <td>{{ r.transaction_items.map((i: any) => `${i.qty}x ${i.product_name}`).join(', ') }}</td>
            <td>{{ rupiah(r.total) }}</td>
            <td>
              <select :value="r.status" :aria-label="'Status ' + r.code" @change="setStatus(r, ($event.target as HTMLSelectElement).value)">
                <option v-for="s in STATUSES" :key="s" :value="s">{{ s }}</option>
              </select>
            </td>
            <td>
              <button class="btn sec sm" @click="openForm(r)">Edit</button>
              <button class="btn danger sm" :disabled="r.stock_deducted" :title="r.stock_deducted ? 'Batalkan transaksi dulu agar stok kembali' : ''" @click="delRow = r">Hapus</button>
            </td>
          </tr>
        </tbody>
      </table>
      <div v-if="filtered.length > 10" class="pager">
        <button class="btn sec sm" :disabled="page <= 1" @click="page--">Sebelumnya</button>
        <span>{{ page }} / {{ pages }}</span>
        <button class="btn sec sm" :disabled="page >= pages" @click="page++">Berikutnya</button>
      </div>
    </div>

    <div v-if="open" class="overlay">
      <form class="modal" novalidate @submit.prevent="save">
        <header>
          <h2>{{ editing ? 'Edit ' + editing.code : 'Transaksi baru' }}</h2>
          <button type="button" class="btn sec sm" @click="open = false">Tutup</button>
        </header>
        <div class="body">
          <div class="f"><label for="cn">Nama pelanggan *</label><input id="cn" v-model="form.customer_name"><div v-if="errs.customer_name" class="err">{{ errs.customer_name }}</div></div>
          <div class="f"><label for="cc">Kontak</label><input id="cc" v-model="form.customer_contact"></div>
          <div class="f"><label for="td">Tanggal transaksi *</label><input id="td" v-model="form.trx_date" type="date"><div v-if="errs.trx_date" class="err">{{ errs.trx_date }}</div></div>
          <div class="f"><label for="src">Sumber transaksi</label><input id="src" v-model="form.source"></div>
          <div class="f" v-if="!editing"><label for="st">Status awal</label>
            <select id="st" v-model="form.status"><option v-for="s in STATUSES" :key="s" :value="s">{{ s }}</option></select>
            <div class="help">Stok berkurang saat status berpindah ke dikonfirmasi atau setelahnya.</div>
          </div>
          <div class="f">
            <label>Item pesanan *</label>
            <p v-if="locked" class="hint">Item terkunci karena stok sudah dikurangi. Ubah status ke baru atau dibatalkan untuk mengedit item.</p>
            <div v-for="(it, i) in form.items" :key="i" class="relrow">
              <select v-model="it.product_id" :disabled="locked" aria-label="Produk" @change="pick(it)">
                <option value="">Pilih produk</option>
                <option v-for="p in products" :key="p.id" :value="p.id">{{ p.name }}</option>
              </select>
              <select v-model="it.variant_id" :disabled="locked || !variantsOf(it).length" aria-label="Varian" @change="pickVariant(it)">
                <option value="">Tanpa varian</option>
                <option v-for="v in variantsOf(it)" :key="v.id" :value="v.id">{{ v.name }}</option>
              </select>
              <input v-model.number="it.qty" type="number" min="1" :disabled="locked" aria-label="Jumlah">
              <input v-model.number="it.unit_price" type="number" min="0" :disabled="locked" aria-label="Harga satuan">
              <button type="button" class="btn danger sm" :disabled="locked" @click="form.items.splice(i, 1)">Hapus</button>
            </div>
            <button type="button" class="btn sec sm" :disabled="locked" @click="form.items.push({ product_id: '', variant_id: '', qty: 1, unit_price: 0 })">Tambah item</button>
            <div v-if="errs.items" class="err">{{ errs.items }}</div>
          </div>
          <div class="f"><label for="dc">Diskon (Rp)</label><input id="dc" v-model.number="form.discount" type="number" min="0"></div>
          <div class="f"><label for="sh">Biaya pengiriman (Rp)</label><input id="sh" v-model.number="form.shipping_fee" type="number" min="0"></div>
          <div class="f"><label for="nt">Catatan admin</label><textarea id="nt" v-model="form.notes" rows="2" /></div>
          <p><strong>Subtotal {{ rupiah(sub) }} · Total {{ rupiah(sub - (form.discount || 0) + (form.shipping_fee || 0)) }}</strong></p>
        </div>
        <footer>
          <button type="button" class="btn sec" @click="open = false">Batal</button>
          <button class="btn" :disabled="saving">{{ saving ? 'Menyimpan...' : 'Simpan' }}</button>
        </footer>
      </form>
    </div>

    <div v-if="delRow" class="overlay">
      <div class="modal sm"><div class="body"><h2>Hapus transaksi {{ delRow.code }}?</h2><p>Data tidak bisa dikembalikan.</p></div>
        <footer><button class="btn sec" @click="delRow = null">Batal</button><button class="btn danger" @click="remove">Hapus</button></footer>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const sb = useSb()
const toast = useToast()
const rows = ref<any[]>([])
const products = ref<any[]>([])
const loading = ref(true)
const q = ref('')
const fstatus = ref('')
const page = ref(1)
const open = ref(false)
const editing = ref<any>(null)
const saving = ref(false)
const delRow = ref<any>(null)
const errs = reactive<any>({})
const form = reactive<any>({ items: [] })

const filtered = computed(() =>
  rows.value.filter((r) => (!fstatus.value || r.status === fstatus.value) && (r.code + r.customer_name).toLowerCase().includes(q.value.toLowerCase()))
)
const pages = computed(() => Math.max(1, Math.ceil(filtered.value.length / 10)))
const paged = computed(() => filtered.value.slice((page.value - 1) * 10, page.value * 10))
const sub = computed(() => form.items.reduce((s: number, i: any) => s + (Number(i.qty) || 0) * (Number(i.unit_price) || 0), 0))
const locked = computed(() => !!editing.value?.stock_deducted)
const variantsOf = (it: any) => products.value.find((p) => p.id === it.product_id)?.product_variants || []

const pick = (it: any) => {
  const p = products.value.find((x) => x.id === it.product_id)
  it.variant_id = ''
  it.unit_price = p ? Number(p.price) : 0
}
const pickVariant = (it: any) => {
  const p = products.value.find((x) => x.id === it.product_id)
  const v = p?.product_variants.find((x: any) => x.id === it.variant_id)
  it.unit_price = Number(v?.price ?? p?.price ?? 0)
}

const load = async () => {
  loading.value = true
  const [t, p] = await Promise.all([
    sb.from('transactions').select('*, transaction_items(*)').order('created_at', { ascending: false }),
    sb.from('products').select('id,name,price,product_variants(id,name,price)').eq('is_archived', false).order('name')
  ])
  if (t.error) toast.err(t.error.message)
  rows.value = t.data || []
  products.value = p.data || []
  loading.value = false
}

const openForm = (r?: any) => {
  editing.value = r || null
  Object.keys(errs).forEach((k) => delete errs[k])
  Object.assign(form, {
    customer_name: r?.customer_name || '',
    customer_contact: r?.customer_contact || '',
    trx_date: r?.trx_date || localDate(new Date()),
    source: r?.source || 'WhatsApp',
    status: r?.status || 'baru',
    discount: r ? Number(r.discount) : 0,
    shipping_fee: r ? Number(r.shipping_fee) : 0,
    notes: r?.notes || '',
    items: r ? r.transaction_items.map((i: any) => ({ product_id: i.product_id || '', variant_id: i.variant_id || '', qty: i.qty, unit_price: Number(i.unit_price) })) : [{ product_id: '', variant_id: '', qty: 1, unit_price: 0 }]
  })
  open.value = true
}

const save = async () => {
  Object.keys(errs).forEach((k) => delete errs[k])
  if (!form.customer_name.trim()) errs.customer_name = 'Wajib diisi'
  if (!form.trx_date) errs.trx_date = 'Wajib diisi'
  if (!form.items.length || form.items.some((i: any) => !i.product_id || !(i.qty > 0) || i.unit_price < 0)) errs.items = 'Lengkapi produk, jumlah, dan harga setiap item'
  if (Object.keys(errs).length) return
  saving.value = true
  const base = {
    customer_name: form.customer_name.trim(),
    customer_contact: form.customer_contact || null,
    trx_date: form.trx_date,
    source: form.source || 'WhatsApp',
    discount: form.discount || 0,
    shipping_fee: form.shipping_fee || 0,
    notes: form.notes || null
  }
  const res = editing.value
    ? await sb.from('transactions').update(base).eq('id', editing.value.id).select('id').single()
    : await sb.from('transactions').insert({ ...base, status: 'baru' }).select('id').single()
  if (res.error) {
    saving.value = false
    return toast.err(res.error.message)
  }
  const id = res.data.id
  if (!locked.value) {
    const del = await sb.from('transaction_items').delete().eq('transaction_id', id)
    if (del.error) {
      saving.value = false
      return toast.err(del.error.message)
    }
    const ins = await sb.from('transaction_items').insert(
      form.items.map((i: any) => {
        const p = products.value.find((x) => x.id === i.product_id)
        const v = p?.product_variants.find((x: any) => x.id === i.variant_id)
        return { transaction_id: id, product_id: i.product_id, variant_id: i.variant_id || null, product_name: p.name, variant_name: v?.name || null, qty: i.qty, unit_price: i.unit_price }
      })
    )
    if (ins.error) {
      saving.value = false
      return toast.err(ins.error.message)
    }
  }
  if (!editing.value && form.status !== 'baru') {
    const st = await sb.from('transactions').update({ status: form.status }).eq('id', id)
    if (st.error) toast.err(st.error.message)
  }
  saving.value = false
  open.value = false
  toast.ok('Transaksi disimpan')
  await load()
}

const setStatus = async (r: any, status: string) => {
  const { error } = await sb.from('transactions').update({ status }).eq('id', r.id)
  if (error) toast.err(error.message)
  else toast.ok('Status diperbarui')
  await load()
}

const remove = async () => {
  const { error } = await sb.from('transactions').delete().eq('id', delRow.value.id)
  delRow.value = null
  error ? toast.err(error.message) : toast.ok('Transaksi dihapus')
  await load()
}

onMounted(load)
</script>