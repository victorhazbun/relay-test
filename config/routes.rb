Rails.application.routes.draw do
  resources :user, only: [] do
    resources :hits, only: [:show]
  end
end
