# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transaction, type: :model do
  let(:transaction) { FactoryBot.create(:transaction) }

  describe 'validations' do
    it { should validate_presence_of(:transaction_id) }
    it { should validate_presence_of(:points) }
    it { should validate_numericality_of(:points).only_integer }
    it { should validate_presence_of(:user_id) }
  end

  describe '.initialize_transaction' do
    let(:transaction_params) { { transaction_id: '12345', points: 100, user_id: '67890' } }

    it 'initializes a new transaction with the given parameters' do
      transaction = Transaction.initialize_transaction(transaction_params)
      expect(transaction).to be_a_new(Transaction)
      expect(transaction.transaction_id).to eq(transaction_params[:transaction_id])
      expect(transaction.points).to eq(transaction_params[:points])
      expect(transaction.user_id).to eq(transaction_params[:user_id])
    end
  end
end
