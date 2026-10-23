import { createClient } from '@supabase/supabase-js'

let client: any

export const useSb = () => {
  if (!client) {
    const c = useRuntimeConfig().public
    client = createClient(c.supabaseUrl || 'http://localhost:54321', c.supabaseKey || 'anon')
  }
  return client
}
