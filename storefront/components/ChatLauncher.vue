<template>
  <div class="cb-fab">
    <Transition name="cbp">
      <section v-show="open" class="cb-panel" role="dialog" aria-label="Asisten Gabin">
        <button class="cb-close" type="button" aria-label="Tutup chat" @click="open = false"><span /><span /></button>
        <FaqChat v-if="opened" />
        <div v-if="numbers.length" class="cb-wa">
          <strong>Butuh bantuan langsung?</strong>
          <div class="cb-wa-row">
            <a v-for="(n, i) in numbers" :key="n.key" class="btn wa small" :class="{ alt: i > 0 }" :href="link(n.number, n.message)" target="_blank" rel="noopener"><WaIcon />{{ n.label }}</a>
          </div>
          <p v-if="numbers.length > 1 && fallbackMessage" class="cb-note">{{ fallbackMessage }}</p>
        </div>
      </section>
    </Transition>
    <button class="cb-btn" type="button" :aria-expanded="open" aria-label="Buka chat FAQ" @click="toggle">
      <svg v-if="!open" class="cb-ico" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
        <path d="M5 4h14a3 3 0 0 1 3 3v8a3 3 0 0 1-3 3h-7l-5 4v-4H5a3 3 0 0 1-3-3V7a3 3 0 0 1 3-3Z" fill="none" stroke="currentColor" stroke-width="2" stroke-linejoin="round" />
        <circle cx="8.5" cy="11" r="1.3" fill="currentColor" /><circle cx="12" cy="11" r="1.3" fill="currentColor" /><circle cx="15.5" cy="11" r="1.3" fill="currentColor" />
      </svg>
      <svg v-else class="cb-ico" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M6 6l12 12M18 6L6 18" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" /></svg>
    </button>
  </div>
</template>

<script setup lang="ts">
const { numbers, fallbackMessage, link } = useWa()
const open = ref(false)
const opened = ref(false)
const toggle = () => {
  open.value = !open.value
  if (open.value) opened.value = true
}
const onKey = (e: KeyboardEvent) => {
  if (e.key === 'Escape') open.value = false
}
onMounted(() => window.addEventListener('keydown', onKey))
onBeforeUnmount(() => window.removeEventListener('keydown', onKey))
</script>

<style>
.cb-fab{position:fixed;left:16px;bottom:16px;z-index:45;display:flex;flex-direction:column;align-items:flex-start;gap:12px}
.cb-btn{width:56px;height:56px;border-radius:50%;border:3px solid var(--ink);background:var(--green);color:var(--ink);display:grid;place-items:center;cursor:pointer;box-shadow:4px 5px 0 var(--green-d);transition:transform .3s var(--ease)}
.cb-btn:hover{transform:translateY(-3px) rotate(-6deg)}
.cb-ico{width:28px;height:28px}
.cb-panel{position:relative;display:flex;flex-direction:column;width:min(380px,calc(100vw - 24px));height:min(600px,calc(100vh - 110px));height:min(600px,calc(100dvh - 110px));background:#fff;border:3px solid var(--ink);border-radius:28px 28px 28px 8px;overflow:hidden;box-shadow:8px 9px 0 var(--ink)}
.cb-close{position:absolute;top:10px;right:10px;z-index:3;width:34px;height:34px;border-radius:50%;border:2.5px solid var(--ink);background:#fff;cursor:pointer}
.cb-close span{position:absolute;left:7px;right:7px;top:14px;height:3px;border-radius:3px;background:var(--ink)}
.cb-close span:first-child{transform:rotate(45deg)}
.cb-close span:last-child{transform:rotate(-45deg)}
.cb-wa{flex:none;display:grid;gap:8px;padding:10px 14px 14px;background:var(--green);border-top:3px solid var(--ink)}
.cb-wa strong{font:600 .95rem var(--f-display);line-height:1.3}
.cb-wa-row{display:flex;gap:8px}
.cb-wa-row .btn{flex:1 1 0;min-width:0;padding:8px 10px;font-size:.85rem}
.cb-wa .btn.wa.alt{background:#fff}
.cb-note{font-size:.8rem;line-height:1.4;color:var(--ink)}
.cbp-enter-active,.cbp-leave-active{transition:opacity .25s,transform .3s var(--ease);transform-origin:bottom left}
.cbp-enter-from,.cbp-leave-to{opacity:0;transform:scale(.88) translateY(12px)}
@media (max-width:520px){.cb-fab{left:10px;bottom:10px}.cb-btn{width:50px;height:50px}}
</style>