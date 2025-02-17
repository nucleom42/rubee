Rubee::Router.draw do |router|
  router.get "/", to: "wellcome#show" # override it for your app

  # Items resource CRUD contracts
  router.get "/items", to: "items#index"
  router.get "/items/{id}", to: "items#show"
  router.post "/items", to: "items#create"
  router.put "/items/{id}", to: "items#update"
  router.delete "/items/{id}", to: "items#delete"

  router.get "/apples", to: "apples#index",
    model: {
      name: "apple",
      attributes: [ { name: 'colour', type: :string }, { name: 'weight', type: :integer } ]
    }
  router.get "/apples/{colour}", to: "apples#show"
end
