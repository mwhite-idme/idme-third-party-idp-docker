Rails.application.routes.draw do
  # EXAMPLE HTML ROUTE
  # get "/photos" => "photos#index"

  root to: "welcome#index"

  #KEYCLOAK CONTROLLER
  get '/keycloak-callback', to: 'keycloak#oauth_callback'
  get '/logout', to: 'keycloak#logout'
  get '/login', to: 'keycloak#login'

end
