Rubee::Router.draw do |router|
  router.get "/", to: "welcome#show" # override it for your app

  # apples
  router.get "/apples", to: "apples#index",
    model: {
      name: "apple",
      attributes: [
        { name: "id", type: "integer" },
        { name: "weight", type: "integer" },
        { name: "color", type: "string" }
      ]
    }
  router.get "/apples/new", to: "apples#new"
  router.post "/apples", to: "apples#create"
  router.get "/apples/{id}", to: "apples#show"
  router.get "/apples/{id}/edit", to: "apples#edit"
  router.patch "/apples/{id}", to: "apples#update"
  router.delete "/apples/{id}", to: "apples#destroy"
end
