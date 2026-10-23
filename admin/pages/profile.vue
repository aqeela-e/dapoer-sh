<template>
  <div>
    <div class="bar"><div><h1>Profil</h1><p class="lead">Kelola akun admin yang sedang masuk.</p></div></div>
    <form class="card pad" style="max-width:480px;display:grid;gap:16px" novalidate @submit.prevent="save">
      <div class="f"><label>Email</label><input :value="email" disabled></div>
      <div class="f"><label for="np">Password baru</label><PasswordInput id="np" v-model="pw" autocomplete="new-password" /><div class="help">Minimal 8 karakter</div></div>
      <div class="f"><label for="cp">Ulangi password baru</label><PasswordInput id="cp" v-model="pw2" autocomplete="new-password" /></div>
      <div v-if="err" class="err" role="alert">{{ err }}</div>
      <div><button class="btn" :disabled="saving">{{ saving ? 'Menyimpan...' : 'Ubah Password' }}</button></div>
    </form>
  </div>
</template>

<script setup lang="ts">
const sb = useSb()
const toast = useToast()
const email = ref('')
const pw = ref('')
const pw2 = ref('')
const err = ref('')
const saving = ref(false)

const save = async () => {
  err.value = ''
  if (pw.value.length < 8) return (err.value = 'Password minimal 8 karakter')
  if (pw.value !== pw2.value) return (err.value = 'Konfirmasi password tidak sama')
  saving.value = true
  const { error } = await sb.auth.updateUser({ password: pw.value })
  saving.value = false
  if (error) return (err.value = error.message)
  pw.value = pw2.value = ''
  toast.ok('Password diperbarui')
}

onMounted(async () => {
  const { data } = await sb.auth.getUser()
  email.value = data.user?.email || ''
})
</script>