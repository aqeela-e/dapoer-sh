<template>
  <div>
    <div class="bar">
      <div><h1>Dashboard</h1><p class="lead">Ringkasan penjualan dan stok dari transaksi yang tercatat.</p></div>
      <div class="tools" style="margin:0">
        <input v-model="from" type="date" aria-label="Dari tanggal" @change="load">
        <input v-model="to" type="date" aria-label="Sampai tanggal" @change="load">
        <select v-model="group" aria-label="Kelompokkan">
          <option value="day">Harian</option>
          <option value="week">Mingguan</option>
          <option value="month">Bulanan</option>
          <option value="year">Tahunan</option>
        </select>
      </div>
    </div>
    <div v-if="loading" class="empty">Memuat data...</div>
    <template v-else>
      <div class="kpis">
        <div class="kpi"><small>Total omzet</small><strong>{{ rupiah(omzet) }}</strong></div>
        <div class="kpi"><small>Unit terjual</small><strong>{{ units }}</strong></div>
        <div class="kpi"><small>Transaksi tercatat</small><strong>{{ trx.length }}</strong></div>
        <div class="kpi"><small>Rata-rata transaksi</small><strong>{{ rupiah(trx.length ? omzet / trx.length : 0) }}</strong></div>
        <div class="kpi"><small>Produk aktif</small><strong>{{ activeCount }}</strong></div>
      </div>
      <div class="card pad">
        <h2 style="margin-bottom:14px">Grafik penjualan</h2>
        <div v-if="!buckets.length" class="empty">Belum ada transaksi pada periode ini.</div>
        <div v-else style="overflow:auto">
          <svg :width="Math.max(480, buckets.length * 56)" height="240" role="img" aria-label="Grafik omzet">
            <g v-for="(b, i) in buckets" :key="b.key">
              <rect :x="i * 56 + 10" :y="200 - (b.value / max) * 170" width="36" :height="(b.value / max) * 170" rx="8" fill="#2563eb" />
              <text :x="i * 56 + 28" y="220" text-anchor="middle" font-size="10" fill="#64748b">{{ b.key.slice(group === 'year' ? 0 : 2) }}</text>
              <text :x="i * 56 + 28" :y="194 - (b.value / max) * 170" text-anchor="middle" font-size="10" fill="#0f172a">{{ short(b.value) }}</text>
            </g>
          </svg>
        </div>
      </div>
      <div class="two">
        <div class="card">
          <h2 class="pad" style="padding-bottom:0">Produk terlaris</h2>
          <div v-if="!top.length" class="empty">Belum ada penjualan.</div>
          <table v-else>
            <thead><tr><th>Produk</th><th>Unit</th><th>Omzet</th></tr></thead>
            <tbody><tr v-for="t in top" :key="t.name"><td>{{ t.name }}</td><td>{{ t.qty }}</td><td>{{ rupiah(t.rev) }}</td></tr></tbody>
          </table>
        </div>
        <div class="card">
          <h2 class="pad" style="padding-bottom:0">Stok menipis</h2>
          <div v-if="!low.length" class="empty">Semua stok aman.</div>
          <table v-else>
            <thead><tr><th>Item</th><th>Stok</th></tr></thead>
            <tbody><tr v-for="l in low" :key="l.name"><td>{{ l.name }}</td><td>{{ l.stock }}</td></tr></tbody>
          </table>
        </div>
      </div>
      <div class="card">
        <h2 class="pad" style="padding-bottom:0">Transaksi terbaru</h2>
        <div v-if="!recent.length" class="empty">Belum ada transaksi. Catat transaksi pertama di menu Transaksi.</div>
        <table v-else>
          <thead><tr><th>Kode</th><th>Tanggal</th><th>Pelanggan</th><th>Status</th><th>Total</th></tr></thead>
          <tbody>
            <tr v-for="r in recent" :key="r.id"><td>{{ r.code }}</td><td>{{ r.trx_date }}</td><td>{{ r.customer_name }}</td><td><span class="chip" :class="statusTone(r.status)">{{ r.status }}</span></td><td>{{ rupiah(r.total) }}</td></tr>
          </tbody>
        </table>
      </div>
    </template>
  </div>
</template>

<script setup lang="ts">
const sb = useSb()
const toast = useToast()
const from = ref(daysAgo(29))
const to = ref(localDate(new Date()))
const group = ref('day')
const loading = ref(true)
const trx = ref<any[]>([])
const recent = ref<any[]>([])
const low = ref<any[]>([])
const activeCount = ref(0)

const net = (t: any) => Number(t.subtotal) - Number(t.discount)
const omzet = computed(() => trx.value.reduce((s, t) => s + net(t), 0))
const units = computed(() => trx.value.reduce((s, t) => s + t.transaction_items.reduce((a: number, i: any) => a + i.qty, 0), 0))

const keyOf = (d: string) => {
  if (group.value === 'month') return d.slice(0, 7)
  if (group.value === 'year') return d.slice(0, 4)
  if (group.value === 'week') {
    const x = new Date(d + 'T00:00:00Z')
    x.setUTCDate(x.getUTCDate() - ((x.getUTCDay() + 6) % 7))
    return x.toISOString().slice(0, 10)
  }
  return d
}

const buckets = computed(() => {
  const m: Record<string, number> = {}
  trx.value.forEach((t) => (m[keyOf(t.trx_date)] = (m[keyOf(t.trx_date)] || 0) + net(t)))
  return Object.keys(m).sort().map((key) => ({ key, value: m[key] }))
})
const max = computed(() => Math.max(1, ...buckets.value.map((b) => b.value)))
const short = (n: number) => (n >= 1e6 ? (n / 1e6).toFixed(1) + 'jt' : n >= 1e3 ? Math.round(n / 1e3) + 'rb' : String(n))

const top = computed(() => {
  const m: Record<string, any> = {}
  trx.value.forEach((t) => t.transaction_items.forEach((i: any) => {
    m[i.product_name] ||= { name: i.product_name, qty: 0, rev: 0 }
    m[i.product_name].qty += i.qty
    m[i.product_name].rev += Number(i.subtotal)
  }))
  return Object.values(m).sort((a: any, b: any) => b.qty - a.qty).slice(0, 5)
})

const load = async () => {
  loading.value = true
  const [t, r, p, v] = await Promise.all([
    sb.from('transactions').select('id,trx_date,subtotal,discount,transaction_items(product_name,qty,subtotal)').in('status', COUNTED).gte('trx_date', from.value).lte('trx_date', to.value),
    sb.from('transactions').select('id,code,customer_name,total,status,trx_date').order('created_at', { ascending: false }).limit(8),
    sb.from('products').select('name,stock,is_published,is_archived,product_variants(id)'),
    sb.from('product_variants').select('name,stock,is_active,products(name)')
  ])
  const err = t.error || r.error || p.error || v.error
  if (err) toast.err(err.message)
  trx.value = t.data || []
  recent.value = r.data || []
  const prods = p.data || []
  activeCount.value = prods.filter((x: any) => x.is_published && !x.is_archived).length
  low.value = [
    ...prods.filter((x: any) => !x.is_archived && !x.product_variants.length && x.stock <= 5).map((x: any) => ({ name: x.name, stock: x.stock })),
    ...(v.data || []).filter((x: any) => x.is_active && x.stock <= 5).map((x: any) => ({ name: `${x.products?.name} - ${x.name}`, stock: x.stock }))
  ]
  loading.value = false
}

onMounted(load)
</script>