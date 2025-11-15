Rubee::Router.draw do |router|
  router.get('/', to: 'welcome#show') # override it for your app
  router.get('/ws', to: 'users#websocket')
end
