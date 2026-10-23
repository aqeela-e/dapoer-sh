export default defineNuxtConfig({
  ssr: false,
  compatibilityDate: '2024-11-01',
  css: ['~/assets/main.css'],
  runtimeConfig: {
    public: {
      supabaseUrl: process.env.SUPABASE_URL || '',
      supabaseKey: process.env.SUPABASE_ANON_KEY || ''
    }
  },
  app: {
    pageTransition: { name: 'page', mode: 'out-in' },
    head: {
      title: 'Gabin Ice Cream',
      htmlAttrs: { lang: 'id' },
      meta: [
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
        { name: 'description', content: 'Gabin Ice Cream - es krim handmade, pesan lewat WhatsApp.' },
        { name: 'theme-color', content: '#F8F7BA' }
      ],
      link: [
        { rel: 'icon', type: 'image/png', href: '/images/logo.png' },
        { rel: 'preconnect', href: 'https://fonts.googleapis.com' },
        { rel: 'preconnect', href: 'https://fonts.gstatic.com', crossorigin: '' },
        { rel: 'stylesheet', href: 'https://fonts.googleapis.com/css2?family=DynaPuff:wght@600&family=Pacifico&family=Fredoka:wght@400;500;600&display=swap' }
      ]
    }
  }
})