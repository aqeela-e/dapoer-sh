<template>
  <div>
    <div class="bar"><h1>Laporan</h1><button class="btn" :disabled="!rows.length" @click="exportCsv">Ekspor CSV</button></div>
    <div class="tools">
      <input v-model="from" type="date" aria-label="Dari tanggal" @change="load">
      <input v-model="to" type="date" aria-label="Sampai tanggal" @change="load">
      <select v-model="fproduct" aria-label="Produk"><option value="">Semua produk</option><option v-for="p in products" :key="p.id" :value="p.id">{{ p.name }}</option></select>
      <select v-model="fcat" aria-label="Kategori"><option value="">Semua kategori</option><option v-for="c in cats" :key="c.id" :value="c.id">{{ c.name }}</option></select>
      <select v-model="fstatus" aria-label="Status"><option value="">Status terhitung</option><option v-for="s in STATUSES" :key="s" :value="s">{{ s }}</option></select>
    </div>
    <div v-if="loading" class="empty">Memuat laporan...</div>
    <template v-else>
      <div class="kpis">
        <div class="kpi"><small>Transaksi</small><strong>{{ trxCount }}</strong></div>
        <div class="kpi"><small>Unit terjual</small><strong>{{ units }}</strong></div>
        <div class="kpi"><small>Omzet bruto</small><strong>{{ rupiah(bruto) }}</strong></div>
        <div class="kpi"><small>Diskon</small><strong>{{ rupiah(discount) }}</strong></div>
        <div class="kpi"><small>Omzet bersih</small><strong>{{ rupiah(bruto - discount) }}</strong></div>
        <div class="kpi"><small>Biaya pengiriman</small><strong>{{ rupiah(shipping) }}</strong></div>
        <div class="kpi"><small>Total diterima</small><strong>{{ rupiah(bruto - discount + shipping) }}</strong></div>
      </div>
      <div class="card">
        <div v-if="!rows.length" class="empty">Tidak ada data untuk filter ini.</div>
        <table v-else>
          <thead><tr><th>Kode</th><th>Tanggal</th><th>Status</th><th>Produk</th><th>Qty</th><th>Harga</th><th>Subtotal</th></tr></thead>
          <tbody>
            <tr v-for="r in rows" :key="r.id">
              <td>{{ r.code }}</td><td>{{ r.trx_date }}</td><td><span class="chip" :class="statusTone(r.status)">{{ r.status }}</span></td>
              <td>{{ r.product_name }}{{ r.variant_name ? ' - ' + r.variant_name : '' }}</td>
              <td>{{ r.qty }}</td><td>{{ rupiah(r.unit_price) }}</td><td>{{ rupiah(r.subtotal) }}</td>
            </tr>
          </tbody>
        </table>
        <p class="legend">Omzet bruto = jumlah subtotal item. Omzet bersih = bruto dikurangi diskon. Total diterima = omzet bersih ditambah biaya pengiriman. Diskon dan ongkir dihitung per transaksi yang memuat item terfilter. Tanpa filter status, hanya transaksi dikonfirmasi, diproses, dikirim, dan selesai yang dihitung.</p>
      </div>
    </template>
  </div>
</template>

<script setup lang="ts">
const sb = useSb()
const toast = useToast()
const from = ref(daysAgo(29))
const to = ref(localDate(new Date()))
const fproduct = ref('')
const fcat = ref('')
const fstatus = ref('')
const loading = ref(true)
const data = ref<any[]>([])
const products = ref<any[]>([])
const cats = ref<any[]>([])

const matchItem = (i: any) => (!fproduct.value || i.product_id === fproduct.value) && (!fcat.value || i.products?.category_id === fcat.value)
const view = computed(() =>
  data.value
    .filter((t) => (fstatus.value ? t.status === fstatus.value : COUNTED.includes(t.status)))
    .map((t) => ({ ...t, matched: t.transaction_items.filter(matchItem) }))
    .filter((t) => t.matched.length)
)
const rows = computed(() => view.value.flatMap((t) => t.matched.map((i: any) => ({ ...i, id: i.id, code: t.code, trx_date: t.trx_date, status: t.status }))))
const trxCount = computed(() => view.value.length)
const units = computed(() => rows.value.reduce((s, r) => s + r.qty, 0))
const bruto = computed(() => rows.value.reduce((s, r) => s + Number(r.subtotal), 0))
const discount = computed(() => view.value.reduce((s, t) => s + Number(t.discount), 0))
const shipping = computed(() => view.value.reduce((s, t) => s + Number(t.shipping_fee), 0))

const load = async () => {
  loading.value = true
  const [t, p, c] = await Promise.all([
    sb.from('transactions').select('*, transaction_items(*, products(category_id))').gte('trx_date', from.value).lte('trx_date', to.value).order('trx_date', { ascending: false }),
    sb.from('products').select('id,name').order('name'),
    sb.from('categories').select('id,name').order('name')
  ])
  if (t.error) toast.err(t.error.message)
  data.value = t.data || []
  products.value = p.data || []
  cats.value = c.data || []
  loading.value = false
}

const exportCsv = () =>
  downloadCsv(`laporan-gabin-${from.value}-${to.value}.csv`, [
    ['Kode', 'Tanggal', 'Status', 'Produk', 'Varian', 'Qty', 'Harga satuan', 'Subtotal'],
    ...rows.value.map((r) => [r.code, r.trx_date, r.status, r.product_name, r.variant_name, r.qty, r.unit_price, r.subtotal])
  ])

onMounted(load)
</script>