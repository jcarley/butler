Rails.application.routes.draw do

  mount BaseApi => '/api'

  root to: 'home#index'

  devise_for :users
  devise_scope :user do
    get "/login" => "devise/sessions#new"
  end
end
