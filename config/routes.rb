Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Autenticação (Rails 8 nativo)
  get "login", to: "sessions#new", as: :login
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout
  resource :session, only: %i[new create destroy]
  resources :passwords, param: :token

  # Rotas Públicas (Fase 2: Busca, Resultados, Categorias, Leads e Contato)
  root "home#index"
  get "buscar", to: "search#index", as: :search
  get "whatsapp_click", to: "leads#whatsapp_click", as: :whatsapp_click
  resources :leads, only: %i[create]
  resources :categories, only: %i[show], param: :slug, path: "categorias"
  resources :products, only: %i[index show], param: :slug, path: "produtos"
  resources :services, only: %i[index show], param: :slug, path: "servicos"
  resources :businesses, only: %i[index show], param: :slug, path: "empresas"

  # Área Autenticada / Comerciante (Protegida)
  get "painel", to: "painel/dashboard#index", as: :painel
  namespace :painel do
    root to: "dashboard#index"
    resource :business, only: %i[show new create edit update], path: "empresa" do
      delete "logo", to: "businesses#purge_logo", as: :purge_logo
      delete "banner", to: "businesses#purge_banner", as: :purge_banner
    end
    resources :products, path: "produtos" do
      member do
        patch :toggle_availability
        delete "images/:image_id", to: "products#purge_image", as: :purge_image
      end
    end
    resources :services, path: "servicos" do
      member do
        patch :toggle_active
        delete "images/:image_id", to: "services#purge_image", as: :purge_image
      end
    end
    resources :leads, only: %i[index show], path: "leads"
    resource :account, only: %i[show update], path: "conta"
  end
end
