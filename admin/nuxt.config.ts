
export default defineNuxtConfig({
  ssr: false,
  compatibilityDate: '2024-11-01',
  css: ['~/assets/admin.css'],

  runtimeConfig: {
    public: {
      supabaseUrl: '',
      supabaseKey: ''
    }
  },

  app: {
    head: {
      title: 'Gabin Admin',
      htmlAttrs: { lang: 'id' },
      meta: [
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
        { name: 'robots', content: 'noindex' }
      ],
      link: [
        { rel: 'preconnect', href: 'https://fonts.googleapis.com' },
        { rel: 'preconnect', href: 'https://fonts.gstatic.com', crossorigin: '' },
        {
          rel: 'stylesheet',
          href: 'https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap'
        }
      ]
    }
  }
})
