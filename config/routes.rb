StartAtlanta::Application.routes.draw do
  resource :facebook do
    get :callback, :to => :create
    post :callback, :to => :create
  end

  resource :subscription

  root :to => 'account#show'

  match "matches/invite"
  match "matches/ready"
  match "matches/view"
  match "matches/waiting"
  match "matches/show", :via => [:get, :post]

  resources :likes
  resources :matches
  resources :users

  match "account/", :to => 'account#show', :via => [:get, :post]
  match "account/show", :via => [:get, :post]
  match "account/loadallfriends"
end
