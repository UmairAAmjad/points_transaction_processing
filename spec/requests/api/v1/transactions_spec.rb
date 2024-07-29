# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::TransactionsController, type: :request do
  describe 'POST /api/v1/transactions/single' do
    let(:valid_attributes) { { transaction_id: '12345', points: 100, user_id: '67890' } }
    let(:invalid_attributes) { { transaction_id: nil, points: nil, user_id: nil } }

    context 'with valid parameters' do
      it 'creates a new Transaction and returns success response' do
        expect do
          post '/api/v1/transactions/single', params: valid_attributes
        end.to change(Transaction, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(response.parsed_body['status']).to eq(I18n.t('transactions.success'))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Transaction and returns error response' do
        expect do
          post '/api/v1/transactions/single', params: invalid_attributes
        end.to change(Transaction, :count).by(0)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body['status']).to eq(I18n.t('transactions.error'))
      end
    end
  end

  describe 'POST /api/v1/transactions/bulk' do
    let(:valid_bulk_attributes) do
      {
        transactions: [
          { transaction_id: '12345', points: 100, user_id: '67890' },
          { transaction_id: '67891', points: 200, user_id: '67892' }
        ]
      }
    end

    let(:large_bulk_attributes) do
      {
        transactions: Array.new(1000) { |i| { transaction_id: "id_#{i}", points: i, user_id: "user_#{i}" } }
      }
    end

    let(:invalid_bulk_attributes) do
      {
        transactions: [
          { transaction_id: nil, points: nil, user_id: nil },
          { transaction_id: nil, points: nil, user_id: nil }
        ]
      }
    end

    context 'with valid bulk parameters less than 1000' do
      it 'processes transactions in batches and returns success response' do
        post '/api/v1/transactions/bulk', params: valid_bulk_attributes

        expect(response).to have_http_status(:created)
        expect(response.parsed_body['status']).to eq(I18n.t('transactions.success'))
      end
    end

    context 'with large bulk parameters greater than or equal to 1000' do
      it 'enqueues the job for processing large batch and returns in-progress response' do
        expect do
          post '/api/v1/transactions/bulk', params: large_bulk_attributes
        end.to have_enqueued_job(ProcessTransactionsBatchJob).exactly(10).times

        expect(response).to have_http_status(:accepted)
        expect(response.parsed_body['status']).to eq(I18n.t('transactions.bulk.in_progress'))
      end
    end

    context 'with invalid bulk parameters' do
      it 'returns error response and does not process transactions' do
        post '/api/v1/transactions/bulk', params: invalid_bulk_attributes

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body['status']).to eq(I18n.t('transactions.error'))
      end
    end
  end
end
