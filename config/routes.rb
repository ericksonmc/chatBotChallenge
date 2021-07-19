Rails.application.routes.draw do
  
  scope '(:locale)', locale: /#{I18n.available_locales.join('|')}/ do
    root 'chats#new'
    resources :chats
  end
  
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
