Rubee::Router.draw do |router|
  router.get "/", to: "wellcome#show" # override it for your app

  router.get "/users/login", to: "users#edit",
    model: {
      name: "user",
      attributes: [
        { name: "id", type: "integer" },
        { name: "email", type: "string" },
        { name: "password", type: "string" }
      ]
    }
  router.post "/users/login", to: "users#login"
  router.get "/users", to: "users#index"
end
