export const useShowcase = () => {
  const sb = useSb()
  const images = useState<string[]>('showcase-images', () => [])
  const loaded = useState<boolean>('showcase-loaded', () => false)
  const load = async () => {
    if (loaded.value) return
    loaded.value = true
    const { data } = await sb
      .from('products')
      .select(PRODUCT_SELECT)
      .eq('is_published', true)
      .eq('is_archived', false)
      .order('is_featured', { ascending: false })
      .order('sort_order')
      .limit(12)
    images.value = (data || []).map(normalizeProduct).map((p: any) => p.images[0]).filter(Boolean).slice(0, 3)
  }
  onMounted(load)
  return { images }
}