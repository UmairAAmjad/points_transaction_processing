# frozen_string_literal: true

module Api
  module V1
    class TransactionsController < Api::ApiController
      include JsonResponse

      def single
        transaction = Transaction.initialize_transaction(transaction_params)

        if transaction.save
          response_format(I18n.t('transactions.success'), { transaction_id: transaction.transaction_id }, :created)
        else
          response_format(I18n.t('transactions.error'), { errors: transaction.errors.full_messages },
                          :unprocessable_entity)
        end
      end

      def bulk
        transaction_service = TransactionProcessingService.new(permitted_bulk_transactions)

        if permitted_bulk_transactions.size >= 1000
          process_large_batch
        else
          process_small_batch(transaction_service)
        end
      end

      private

      def transaction_params
        params.permit(:transaction_id, :points, :user_id)
      end

      def permitted_bulk_transactions
        transactions = params[:transactions]

        transactions.map do |transaction|
          transaction.permit(:transaction_id, :points, :user_id)
        end
      end

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
end
