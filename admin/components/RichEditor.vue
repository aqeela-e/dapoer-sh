<template>
  <div class="editor">
    <div class="tb" role="toolbar" aria-label="Format teks">
      <button type="button" title="Tebal" @mousedown.prevent="cmd('bold')">B</button>
      <button type="button" title="Miring" @mousedown.prevent="cmd('italic')"><i>I</i></button>
      <button type="button" title="Daftar bullet" @mousedown.prevent="cmd('insertUnorderedList')">• List</button>
      <button type="button" title="Daftar angka" @mousedown.prevent="cmd('insertOrderedList')">1. List</button>
      <button type="button" title="Tautan" @mousedown.prevent="link">Link</button>
    </div>
    <div ref="el" class="ed" contenteditable="true" role="textbox" aria-multiline="true" @input="emit('update:modelValue', el!.innerHTML)" />
  </div>
</template>

<script setup lang="ts">
const props = defineProps<{ modelValue: string }>()
const emit = defineEmits(['update:modelValue'])
const el = ref<HTMLElement>()

const sync = () => {
  if (el.value && el.value.innerHTML !== (props.modelValue || '')) el.value.innerHTML = props.modelValue || ''
}

const cmd = (c: string) => {
  document.execCommand(c)
  emit('update:modelValue', el.value!.innerHTML)
}

const link = () => {
  const url = prompt('Masukkan URL (https://...)')
  if (url && /^https?:\/\//i.test(url)) {
    document.execCommand('createLink', false, url)
    emit('update:modelValue', el.value!.innerHTML)
  }
}

onMounted(sync)
watch(() => props.modelValue, sync)
</script>
