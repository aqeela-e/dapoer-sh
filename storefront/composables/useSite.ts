export const useSite = () => {
  const sb = useSb()
  const state = useState<any>('site', () => ({ loaded: false, wa: null, settings: {} }))
  const load = async () => {
    if (state.value.loaded) return
    const [wa, st] = await Promise.all([
      sb.from('whatsapp_settings').select('*').eq('id', 1).maybeSingle(),
      sb.from('site_settings').select('*')
    ])
    state.value = {
      loaded: true,
      wa: wa.data,
      settings: Object.fromEntries((st.data || []).map((r: any) => [r.key, r.value]))
    }
  }
  return { state, load }
}
