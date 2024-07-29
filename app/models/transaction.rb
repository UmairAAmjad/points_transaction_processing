# frozen_string_literal: true

class Transaction < ApplicationRecord
  validates :transaction_id, presence: true
  validates :points, presence: true, numericality: { only_integer: true }
  validates :user_id, presence: true

  def self.initialize_transaction(transaction_params)
    Transaction.new(transaction_params)
  end
end
