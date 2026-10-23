<template>
  <Teleport to="body">
    <Transition name="lb">
      <div v-if="src" class="lb" role="dialog" aria-modal="true" :aria-label="alt" @click.self="$emit('close')">
        <button class="lb-x" type="button" aria-label="Tutup" @click="$emit('close')"><span /><span /></button>
        <img class="lb-img" :src="src" :alt="alt">
      </div>
    </Transition>
  </Teleport>
</template>

<script setup lang="ts">
const props = defineProps<{ src: string | null; alt?: string }>()
const emit = defineEmits(['close'])
const onKey = (e: KeyboardEvent) => {
  if (e.key === 'Escape' && props.src) emit('close')
}
watch(
  () => props.src,
  (v) => {
    document.body.style.overflow = v ? 'hidden' : ''
  }
)
onMounted(() => window.addEventListener('keydown', onKey))
onBeforeUnmount(() => {
  window.removeEventListener('keydown', onKey)
  document.body.style.overflow = ''
})
</script>

<style>
.lb{position:fixed;inset:0;z-index:80;background:rgba(58,46,79,.82);display:grid;place-items:center;padding:20px}
.lb-img{max-width:min(520px,100%);max-height:92vh;width:auto;height:auto;border:3px solid var(--ink);border-radius:24px;background:#fff;box-shadow:8px 10px 0 rgba(0,0,0,.25)}
.lb-x{position:absolute;top:16px;right:16px;width:46px;height:46px;border-radius:50%;border:2.5px solid var(--ink);background:#fff;cursor:pointer}
.lb-x span{position:absolute;left:11px;right:11px;top:20px;height:3px;border-radius:3px;background:var(--ink)}
.lb-x span:first-child{transform:rotate(45deg)}
.lb-x span:last-child{transform:rotate(-45deg)}
.lb-enter-active,.lb-leave-active{transition:opacity .25s}
.lb-enter-from,.lb-leave-to{opacity:0}
</style>