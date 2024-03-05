import { NuxtAuthHandler } from '#auth'
import GithubProvider from 'next-auth/providers/github'

const runtimeConfig = useRuntimeConfig()

export default NuxtAuthHandler({
  pages: {
    signIn: '/login'
  },
  providers: [
    // @ts-expect-error
    GithubProvider.default({
      clientId: runtimeConfig.CLIENT_ID,
      clientSecret: runtimeConfig.CLIENT_SECRET
    })
  ]
})
