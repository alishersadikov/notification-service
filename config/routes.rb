# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      resources :notifications, only: [:index, :show, :create]
      resources :providers, only: [:index, :show, :create]
    end
  end

  post '/delivery_status', to: 'callbacks#text_message'
end
