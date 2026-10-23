<template>
  <div>
    <div class="bar"><h1>Stok</h1><button class="btn" @click="openForm">Sesuaikan Stok</button></div>
    <div class="card">
      <div v-if="loading" class="empty">Memuat stok...</div>
      <div v-else-if="!items.length" class="empty">Belum ada produk.</div>
      <table v-else>
        <thead><tr><th>Item</th><th>Stok</th><th>Peringatan</th></tr></thead>
        <tbody>
          <tr v-for="i in items" :key="i.key">
            <td>{{ i.name }}</td><td>{{ i.stock }}</td>
            <td><span class="chip" :class="{ on: i.stock > 5 }">{{ i.stock <= 0 ? 'Habis' : i.stock <= 5 ? 'Menipis' : 'Aman' }}</span></td>
          </tr>
        </tbody>
      </table>
    </div>
    <div class="card">
      <h2 class="pad" style="padding-bottom:0">Riwayat perubahan stok</h2>
      <div v-if="!moves.length" class="empty">Belum ada perubahan stok.</div>
      <table v-else>
        <thead><tr><th>Waktu</th><th>Produk</th><th>Perubahan</th><th>Alasan</th></tr></thead>
        <tbody>
          <tr v-for="m in moves" :key="m.id">
            <td>{{ fmtDateTime(m.created_at) }}</td>
            <td>{{ m.products?.name || '-' }}{{ m.product_variants?.name ? ' - ' + m.product_variants.name : '' }}</td>
            <td>{{ m.change > 0 ? '+' + m.change : m.change }}</td>
            <td>{{ m.reason }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="open" class="overlay">
      <form class="modal sm" novalidate @submit.prevent="save">
        <header><h2>Sesuaikan stok</h2></header>
        <div class="body">
          <div class="f"><label for="it">Item *</label>
            <select id="it" v-model="sel"><option value="">Pilih item</option><option v-for="i in items" :key="i.key" :value="i.key">{{ i.name }}</option></select>
          </div>
          <div class="f"><label for="ch">Perubahan (+ tambah, - kurang) *</label><input id="ch" v-model.number="change" type="number"></div>
          <div class="f"><label for="rs">Alasan *</label><input id="rs" v-model="reason"></div>
          <div v-if="err" class="err" role="alert">{{ err }}</div>
        </div>
        <footer><button type="button" class="btn sec" @click="open = false">Batal</button><button class="btn">Simpan</button></footer>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
const sb = useSb()
const toast = useToast()
const loading = ref(true)
const items = ref<any[]>([])
const moves = ref<any[]>([])
const open = ref(false)
const sel = ref('')
const change = ref(0)
const reason = ref('')
const err = ref('')

const load = async () => {
  loading.value = true
  const [p, m] = await Promise.all([
    sb.from('products').select('id,name,stock,product_variants(id,name,stock)').eq('is_archived', false).order('name'),
    sb.from('inventory_movements').select('*, products(name), product_variants(name)').order('created_at', { ascending: false }).limit(100)
  ])
  items.value = (p.data || []).flatMap((x: any) =>
    x.product_variants.length
      ? x.product_variants.map((v: any) => ({ key: `${x.id}|${v.id}`, name: `${x.name} - ${v.name}`, stock: v.stock }))
      : [{ key: `${x.id}|`, name: x.name, stock: x.stock }]
  )
  moves.value = m.data || []
  loading.value = false
}

const openForm = () => {
  sel.value = ''
  change.value = 0
  reason.value = ''
  err.value = ''
  open.value = true
}

const save = async () => {
  if (!sel.value || !change.value || !reason.value.trim()) return (err.value = 'Pilih item, isi perubahan bukan nol, dan isi alasan')
  const [pid, vid] = sel.value.split('|')
  const { error } = await sb.rpc('adjust_stock', { p_product: pid, p_variant: vid || null, p_change: change.value, p_reason: reason.value.trim() })
  if (error) return (err.value = error.message)
  open.value = false
  toast.ok('Stok diperbarui')
  await load()
}

onMounted(load)
</script>
