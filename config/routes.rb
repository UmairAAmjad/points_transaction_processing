# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post 'transactions/single', to: 'transactions#single'
      post 'transactions/bulk', to: 'transactions#bulk'
    end
  end
end
