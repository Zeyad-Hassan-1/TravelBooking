Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  resources :flights, only: [ :index, :show ]
  resources :bookings
  post "create_checkout_session", to: "payments#create_checkout_session"  # ده هيتعامل مع الطلبات الخاصة بالدفع
  get "success", to: "payments#success"  # صفحة النجاح
  get "cancel", to: "payments#cancel"    # صفحة الإلغاء
  post "/webhooks/stripe", to: "webhooks#stripe"
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  # Defines the root path route ("/")
  root "flights#index"
end
