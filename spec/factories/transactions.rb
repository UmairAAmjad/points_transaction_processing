# frozen_string_literal: true

# spec/factories/transactions.rb

FactoryBot.define do
  factory :transaction do
    transaction_id { SecureRandom.uuid }
    points { rand(1..1000) }
    user_id { SecureRandom.uuid }
  end
end
