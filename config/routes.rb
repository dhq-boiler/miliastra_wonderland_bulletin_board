Rails.application.routes.draw do
  # Active Storage routes for file uploads
  # This must be at the top to handle /rails/active_storage/* routes
  if Rails.application.config.active_storage.draw_routes
    # Rails 7.1+ automatically draws Active Storage routes
  end

  resources :stages
  resources :multiplay_recruitments do
    resources :comments, only: [ :create, :destroy ], controller: "multiplay_recruitment_comments"
    resource :participant, only: [ :create, :destroy ], controller: "multiplay_recruitment_participants"
  end

  # 認証関連
  get "signup", to: "users#new", as: "signup"
  post "signup", to: "users#create"
  get "login", to: "sessions#new", as: "login"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: "logout"

  # OmniAuth
  get "/auth/:provider/callback", to: "omniauth_callbacks#google_oauth2"
  post "/auth/:provider/callback", to: "omniauth_callbacks#google_oauth2"
  get "/auth/failure", to: "omniauth_callbacks#failure"

  # ユーザープロファイル
  get "profile", to: "users#edit", as: "profile"
  patch "profile", to: "users#update"
  put "profile", to: "users#update"

  # ユーザーの公開プロフィール（クリエイターページ）
  resources :users, only: [ :show ]

  # パスワードリセット
  resources :password_resets, only: [ :new, :create, :edit, :update ]

  get "welcome/index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "stages#index"
end
