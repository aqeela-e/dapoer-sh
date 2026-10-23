export const useWa = () => {
  const { state } = useSite()
  const numbers = computed(() => {
    const w = state.value.wa
    if (!w) return []
    return [
      { key: 'main', label: w.label_primary, number: w.number_primary, message: WA_MESSAGES.order },
      { key: 'alt', label: w.label_secondary, number: w.number_secondary, message: WA_MESSAGES.help }
    ].filter((n) => n.number)
  })
  const fallbackMessage = computed(() => state.value.wa?.fallback_message || '')
  const link = (number: string, text: string) => `https://wa.me/${String(number).replace(/\D/g, '')}?text=${encodeURIComponent(text)}`
  const askLink = (number: string, question: string) => link(number, WA_MESSAGES.question.replace('{pertanyaan}', question))
  return { numbers, fallbackMessage, link, askLink, state }
}