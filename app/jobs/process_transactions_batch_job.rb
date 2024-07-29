# frozen_string_literal: true

class ProcessTransactionsBatchJob < ApplicationJob
  queue_as :default

  def perform(transaction_data)
    TransactionProcessingService.new(transaction_data).process_batch(transaction_data)
  end
end
