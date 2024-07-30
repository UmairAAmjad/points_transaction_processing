# frozen_string_literal: true

# app/controllers/concerns/transaction_processing.rb
module TransactionProcessable
  extend ActiveSupport::Concern

  included do
    private

    def process_large_batch
      batch_size = 100
      permitted_bulk_transactions.each_slice(batch_size) do |transaction_data|
        ProcessTransactionsBatchJob.perform_later(transaction_data)
      end
      response_format(I18n.t('transactions.bulk.in_progress'),
                      { message: I18n.t('transactions.bulk.in_progress_message') }, :accepted)
    end

    def process_small_batch(transaction_service)
      result = transaction_service.process_in_batches
      if result[:errors].empty?
        response_format(I18n.t('transactions.success'), { processed_count: result[:total_count] }, :created)
      else
        response_format(I18n.t('transactions.error'), { errors: result[:errors] }, :unprocessable_entity)
      end
    end
  end
end
