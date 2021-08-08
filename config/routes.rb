Rails.application.routes.draw do
  resources :articles, only: [:index]
  get '/', to: 'articles#index'
  post '/fetch_articles', to: 'articles#fetch_articles'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
