export default defineNuxtConfig({
  devtools: { enabled: true },
  modules: ['@sidebase/nuxt-auth', '@nuxt/ui', '@pinia/nuxt'],
  colorMode: {
    preference: 'light' // default: system
  },
  auth: {
          enableGlobalAppMiddleware: true,
  },
  app: {
      head: {
          link: [{ rel: 'icon', type: 'image/png', href: '/favicon.png' }]
      }
  },
  runtimeConfig: {
          CLIENT_ID: process.env.CLIENT_ID,
          CLIENT_SECRET: process.env.CLIENT_SECRET
  }
})

