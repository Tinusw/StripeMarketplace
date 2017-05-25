Rails.application.routes.draw do
  devise_for :users

  devise_scope :user do
    authenticated :user do
      root 'merchants#index'
    end
    unauthenticated do
      root 'devise/sessions#new'
    end
  end

  resources :merchants

  resources :user do
    resources :merchants do
      resources :items
    end
  end
end
