export default defineNuxtPlugin((nuxtApp) => {
  let io: IntersectionObserver | null = null
  const reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches
  const observer = () => {
    if (!io) {
      io = new IntersectionObserver(
        (entries) => {
          entries.forEach((e) => {
            if (e.isIntersecting) {
              e.target.classList.add('in')
              io?.unobserve(e.target)
            }
          })
        },
        { threshold: 0.12, rootMargin: '0px 0px -6% 0px' }
      )
    }
    return io
  }
  nuxtApp.vueApp.directive('reveal', {
    mounted(el: HTMLElement, binding) {
      el.classList.add('rv')
      if (binding.value) el.style.setProperty('--d', `${binding.value}ms`)
      if (reduce) {
        el.classList.add('in')
        return
      }
      observer().observe(el)
    },
    unmounted(el: HTMLElement) {
      io?.unobserve(el)
    }
  })
})