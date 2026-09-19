Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Autenticação (Rails 8 nativo)
  get "login", to: "sessions#new", as: :login
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout
  resource :session, only: %i[new create destroy]
  resources :passwords, param: :token

  # Rotas Públicas (Fase 1: Home base + estruturas para Fase 2)
  root "home#index"
  get "buscar", to: "home#search", as: :search

  resources :products, only: %i[index show], param: :slug, path: "produtos"
  resources :services, only: %i[index show], param: :slug, path: "servicos"
  resources :businesses, only: %i[index show], param: :slug, path: "empresas"

  # Área Autenticada / Comerciante (Protegida)
  get "painel", to: "painel/dashboard#index", as: :painel
  namespace :painel do
    root to: "dashboard#index"
    resource :business, only: %i[show new create edit update], path: "empresa"
    resources :products, path: "produtos"
    resources :services, path: "servicos"
    resources :leads, only: %i[index show], path: "leads"
  end
end
