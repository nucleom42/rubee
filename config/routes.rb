Rubee::Router.draw do |router|
  router.get "/", to: "wellcome#show" # override it for your app
end
