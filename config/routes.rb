Rails.application.routes.draw do
  resources :user, only: [] do
    resources :products, only: [:show]
  end
end
