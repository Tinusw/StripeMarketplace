Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: 'omniauth_callbacks'
  }

  devise_scope :user do
    authenticated :user do
      root 'merchants#index'
    end
    unauthenticated do
      root 'devise/sessions#new'
    end
  end

  resources :admin do
    resources :users do
      collection do
        put :approve
      end
    end
  end

  resources :transactions

  resources :merchants do
    resources :items
    resources :transactions
  end

  resources :users do
    resources :merchants
    resources :transactions
  end
end
