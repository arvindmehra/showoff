Rails.application.routes.draw do
  resources :users do
    collection do
      post 'register'
      post 'sign_in'
      delete "logout"
      post 'reset_password'
    end
  end

  resources :widgets
  root 'widgets#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
