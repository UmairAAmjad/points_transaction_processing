# frozen_string_literal: true

class Transaction < ApplicationRecord
  BULKDATANUMBER = 1000 # Just an assumption. Can be any value.

  validates :transaction_id, presence: true, uniqueness: true
  validates :points, presence: true, numericality: { only_integer: true }
  validates :user_id, presence: true

  def self.initialize_transaction(transaction_params)
    Transaction.new(transaction_params)
  end
end
