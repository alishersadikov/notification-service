Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  namespace :api do 
    namespace :v1 do 
      post '/send_text', to: "notifications#create"
    end 
  end 

  post '/delivery_status', to: 'callbacks#text'
end
