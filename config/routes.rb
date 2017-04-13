Rails.application.routes.draw do
  root 'users#index'
  get 'users/show'
  devise_for :users
  resources :users, :only => [:index, :show]
  resources :foods do
    member { get :image }
  end
end
