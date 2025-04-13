Rubee::Router.draw do |router|
  router.get('/', to: 'welcome#show') # override it for your app
  router.get('/api/not_found', to: 'welcome#not_found')

  router.get('/api/users', model: { name: 'User' }, to: 'users#index', react: { view_name: 'user.tsx' })
end
