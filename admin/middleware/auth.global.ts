export default defineNuxtRouteMiddleware(async (to) => {
  const { data } = await useSb().auth.getSession()
  if (!data.session && to.path !== '/login') return navigateTo('/login')
  if (data.session && to.path === '/login') return navigateTo('/')
})
