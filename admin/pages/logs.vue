<template>
  <div>
    <div class="bar"><div><h1>Aktivitas</h1><p class="lead">Riwayat perubahan data oleh admin.</p></div></div>
    <div class="card">
      <div v-if="loading" class="empty">Memuat aktivitas...</div>
      <div v-else-if="!rows.length" class="empty">Belum ada aktivitas tercatat.</div>
      <table v-else>
        <thead><tr><th>Waktu</th><th>Aksi</th><th>Data</th><th>Keterangan</th></tr></thead>
        <tbody>
          <tr v-for="r in rows" :key="r.id">
            <td>{{ fmtDateTime(r.created_at) }}</td><td>{{ r.action }}</td><td>{{ r.entity }}</td><td>{{ r.detail?.label || '-' }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup lang="ts">
const sb = useSb()
const rows = ref<any[]>([])
const loading = ref(true)
onMounted(async () => {
  const { data } = await sb.from('admin_activity_logs').select('*').order('created_at', { ascending: false }).limit(200)
  rows.value = data || []
  loading.value = false
})
</script>