export const useToast = () => {
  const list = useState<any[]>('toasts', () => [])
  const push = (type: string, text: string) => {
    const id = Date.now() + Math.random()
    list.value = [...list.value, { id, type, text }]
    setTimeout(() => (list.value = list.value.filter((t) => t.id !== id)), 4000)
  }
  return { list, ok: (t: string) => push('ok', t), err: (t: string) => push('err', t) }
}
