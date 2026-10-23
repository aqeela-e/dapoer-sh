<template>
  <div class="login">
    <section class="login-side">
      <div class="brand">
        <span class="brand-mark">G</span>
        <div><strong>Gabin Ice Cream</strong><small>Panel Admin</small></div>
      </div>
      <div>
        <h2>Kelola toko Gabin dari satu tempat.</h2>
        <p>Atur produk, jadwal pre-order, konten website, dan pesanan WhatsApp.</p>
      </div>
      <small>Akses khusus admin</small>
    </section>
    <section class="login-main">
      <form @submit.prevent="submit">
        <div>
          <h1>Masuk</h1>
        </div>
        <p class="sub">Gunakan akun admin untuk melanjutkan.</p>
        <div class="f">
          <label for="email">Email</label>
          <input id="email" v-model="email" type="email" required autocomplete="username" placeholder="nama@email.com">
        </div>
        <div class="f">
          <label for="pw">Password</label>
          <PasswordInput id="pw" v-model="password" required autocomplete="current-password" />
        </div>
        <p v-if="error" class="f"><span class="err" role="alert">{{ error }}</span></p>
        <button class="btn" :disabled="loading">{{ loading ? 'Memproses...' : 'Masuk' }}</button>
      </form>
    </section>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: false })
const sb = useSb()
const email = ref('')
const password = ref('')
const error = ref('')
const loading = ref(false)

const submit = async () => {
  loading.value = true
  error.value = ''
  const { data, error: e } = await sb.auth.signInWithPassword({ email: email.value, password: password.value })
  if (e) {
    error.value = 'Email atau password salah.'
    loading.value = false
    return
  }
  const { data: adm } = await sb.from('admins').select('user_id').eq('user_id', data.user.id).maybeSingle()
  if (!adm) {
    await sb.auth.signOut()
    error.value = 'Akun ini tidak memiliki akses admin.'
    loading.value = false
    return
  }
  await navigateTo('/')
}
</script>