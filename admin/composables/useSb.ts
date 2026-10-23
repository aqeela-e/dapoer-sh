
import { createClient } from '@supabase/supabase-js'

let client: ReturnType<typeof createClient> | null = null

export const useSb = () => {
  if (!client) {
    const config = useRuntimeConfig().public
    const supabaseUrl = config.supabaseUrl
    const supabaseKey = config.supabaseKey

    if (!supabaseUrl || !supabaseKey) {
      throw new Error(
        'Supabase belum dikonfigurasi. Periksa SUPABASE_URL dan SUPABASE_ANON_KEY.'
      )
    }

    client = createClient(supabaseUrl, supabaseKey)
  }

  return client
}
