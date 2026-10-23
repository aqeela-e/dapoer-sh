<template>
  <div class="pw">
    <input
      :id="id"
      :value="modelValue"
      :type="show ? 'text' : 'password'"
      :autocomplete="autocomplete"
      :placeholder="placeholder"
      :required="required"
      @input="emit('update:modelValue', ($event.target as HTMLInputElement).value)"
    >
    <button type="button" class="pw-eye" :aria-label="show ? 'Sembunyikan password' : 'Tampilkan password'" :aria-pressed="show" @click="show = !show">
      <svg v-if="!show" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M1 12s4-7 11-7 11 7 11 7-4 7-11 7S1 12 1 12z" /><circle cx="12" cy="12" r="3" /></svg>
      <svg v-else viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M17.9 17.9A10.9 10.9 0 0 1 12 19c-7 0-11-7-11-7a19.8 19.8 0 0 1 5.1-5.9M9.9 5.2A10.4 10.4 0 0 1 12 5c7 0 11 7 11 7a19.9 19.9 0 0 1-3.2 4.2M14.1 14.1a3 3 0 1 1-4.2-4.2M1 1l22 22" /></svg>
    </button>
  </div>
</template>

<script setup lang="ts">
defineProps<{ modelValue: string; id?: string; autocomplete?: string; placeholder?: string; required?: boolean }>()
const emit = defineEmits(['update:modelValue'])
const show = ref(false)
</script>

<style>
.pw{position:relative}
.pw input{padding-right:44px}
.pw-eye{position:absolute;top:50%;right:6px;transform:translateY(-50%);width:34px;height:34px;border:0;background:transparent;border-radius:6px;display:grid;place-items:center;cursor:pointer;color:#64748b}
.pw-eye:hover{background:#f1f5f9;color:#0f172a}
.pw-eye svg{width:18px;height:18px;fill:none;stroke:currentColor;stroke-width:1.9;stroke-linecap:round;stroke-linejoin:round}
</style>