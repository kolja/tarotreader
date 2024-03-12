export default defineNuxtConfig({
  ssr: false,
  css: ['~/assets/css/tarot.css'],
  devtools: {
    enabled: true,

    timeline: {
      enabled: true
    }
  },
  modules: ['@sidebase/nuxt-auth', '@nuxt/ui', '@pinia/nuxt', '@vueuse/nuxt'],
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