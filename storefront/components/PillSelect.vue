<template>
  <div ref="root" class="ps">
    <button
      type="button"
      class="ps-btn"
      :class="{ open }"
      aria-haspopup="listbox"
      :aria-expanded="open"
      :aria-label="ariaLabel"
      @click="toggle"
      @keydown="onKey"
    >
      <span class="ps-label">{{ current.label }}</span>
      <svg class="ps-chev" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M6 9l6 6 6-6" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" /></svg>
    </button>
    <Transition name="ps">
      <ul v-show="open" class="ps-list" role="listbox" :aria-label="ariaLabel">
        <li
          v-for="(o, i) in options"
          :key="o.value"
          role="option"
          :aria-selected="o.value === modelValue"
          :class="{ on: o.value === modelValue, act: i === active }"
          @mouseenter="active = i"
          @click="pick(o.value)"
        >
          <span>{{ o.label }}</span>
          <svg v-if="o.value === modelValue" class="ps-check" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M5 12.5l4.5 4.5L19 7.5" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" /></svg>
        </li>
      </ul>
    </Transition>
  </div>
</template>

<script setup lang="ts">
const props = defineProps<{ modelValue: string; options: { value: string; label: string }[]; ariaLabel?: string }>()
const emit = defineEmits(['update:modelValue'])
const open = ref(false)
const active = ref(0)
const root = ref<HTMLElement>()
const current = computed(() => props.options.find((o) => o.value === props.modelValue) || props.options[0])

const show = () => {
  active.value = Math.max(0, props.options.findIndex((o) => o.value === props.modelValue))
  open.value = true
}
const toggle = () => (open.value ? (open.value = false) : show())
const pick = (v: string) => {
  emit('update:modelValue', v)
  open.value = false
}
const onKey = (e: KeyboardEvent) => {
  if (e.key === 'Escape') {
    open.value = false
    return
  }
  if (e.key === 'ArrowDown' || e.key === 'ArrowUp') {
    e.preventDefault()
    if (!open.value) return show()
    const n = props.options.length
    active.value = (active.value + (e.key === 'ArrowDown' ? 1 : n - 1)) % n
    return
  }
  if ((e.key === 'Enter' || e.key === ' ') && open.value) {
    e.preventDefault()
    pick(props.options[active.value].value)
  }
}
const outside = (e: MouseEvent) => {
  if (root.value && !root.value.contains(e.target as Node)) open.value = false
}
onMounted(() => document.addEventListener('click', outside))
onBeforeUnmount(() => document.removeEventListener('click', outside))
</script>

<style>
.ps{position:relative;flex:0 0 auto;min-width:230px}
.ps-btn{width:100%;display:flex;align-items:center;justify-content:space-between;gap:12px;padding:11px 18px 11px 22px;border-radius:999px;border:2.5px solid var(--ink);background:#fff;color:var(--ink);font:500 1rem var(--f-body);line-height:1.3;cursor:pointer;box-shadow:3px 4px 0 var(--blue);transition:transform .25s var(--ease),box-shadow .25s var(--ease),background .2s}
.ps-btn:hover{transform:translate(-1px,-2px);box-shadow:5px 7px 0 var(--blue);background:var(--yellow)}
.ps-btn.open{background:var(--yellow)}
.ps-chev{width:20px;height:20px;flex:none;transition:transform .3s var(--ease)}
.ps-btn.open .ps-chev{transform:rotate(180deg)}
.ps-list{position:absolute;top:calc(100% + 12px);left:0;min-width:100%;z-index:30;list-style:none;margin:0;padding:8px;background:#fff;border:2.5px solid var(--ink);border-radius:26px;box-shadow:6px 8px 0 var(--ink)}
.ps-list li{display:flex;align-items:center;justify-content:space-between;gap:14px;padding:10px 16px;border-radius:18px;font:500 1rem var(--f-body);line-height:1.3;cursor:pointer;white-space:nowrap}
.ps-list li.act{background:var(--yellow)}
.ps-list li.on{background:var(--pink);font-weight:600}
.ps-check{width:18px;height:18px;flex:none}
.ps-enter-active,.ps-leave-active{transition:opacity .2s,transform .25s var(--ease);transform-origin:top left}
.ps-enter-from,.ps-leave-to{opacity:0;transform:translateY(-8px) scale(.96)}
@media (max-width:520px){.ps{flex:1 1 100%}}
@media (prefers-reduced-motion:reduce){.ps-btn,.ps-chev{transition:none}}
</style>