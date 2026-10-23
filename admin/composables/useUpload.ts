export const useUpload = () => {
  const sb = useSb()
  return async (file: File) => {
    const name = `${Date.now()}-${file.name.replace(/[^a-zA-Z0-9._-]/g, '_')}`
    const { error } = await sb.storage.from('gabin-media').upload(name, file, { upsert: false })
    if (error) throw error
    return sb.storage.from('gabin-media').getPublicUrl(name).data.publicUrl as string
  }
}
