Rails.application.routes.draw do
  root to: 'home#index', as: 'root'
  post '/payload', to: 'assignments#payload', as: 'payload'
  post '/attendance', to: 'students#attendance', as: 'attendance'
  
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
