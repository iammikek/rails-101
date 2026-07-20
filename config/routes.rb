Rails.application.routes.draw do
  get "/", to: "health#root"
  get "/health", to: "health#health"
  get "up" => "rails/health#show", as: :rails_health_check

  # JSON API (no /api prefix — matches *-101 family URLs)
  post "/auth/register", to: "auth#register"
  post "/auth/login", to: "auth#login"
  get "/auth/me", to: "auth#me"

  get "/items/stats/summary", to: "items#stats"
  get "/items", to: "items#index"
  get "/items/:id", to: "items#show", constraints: { id: /\d+/ }
  post "/items", to: "items#create"
  patch "/items/:id", to: "items#update", constraints: { id: /\d+/ }
  delete "/items/:id", to: "items#destroy", constraints: { id: /\d+/ }

  get "/categories", to: "categories#index"
  get "/categories/:id", to: "categories#show", constraints: { id: /\d+/ }
  post "/categories", to: "categories#create"
  patch "/categories/:id", to: "categories#update", constraints: { id: /\d+/ }
  delete "/categories/:id", to: "categories#destroy", constraints: { id: /\d+/ }

  # Catalog Shop — server-rendered ERB + session auth
  scope path: "/shop", as: "shop", module: "shop" do
    get "/", to: "home#home", as: :home
    match "/login", to: "auth#login", via: [ :get, :post ], as: :login
    post "/logout", to: "auth#logout", as: :logout
    match "/register", to: "auth#register", via: [ :get, :post ], as: :register
    get "/items", to: "items#index", as: :items
    get "/items/new", to: "items#new", as: :new_item
    post "/items/new", to: "items#create"
    get "/items/:id", to: "items#show", as: :item, constraints: { id: /\d+/ }
  end
end
