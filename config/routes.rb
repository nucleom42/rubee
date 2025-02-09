Rubee::Router.draw do |router|
  router.get "/", to: "wellcome#show"
  router.get "/hello", to: "hello#index"
  router.get "/hello/{id}", to: "hello#show"
  router.post "/hello", to: "hello#create"
  router.put "/hello/{id}", to: "hello#update"
  router.delete "/hello/{id}", to: "hello#delete"
end
