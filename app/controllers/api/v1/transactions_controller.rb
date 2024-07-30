# frozen_string_literal: true

module Api
  module V1
    class TransactionsController < Api::ApiController
      include JsonResponse
      include TransactionProcessable

      def single
        transaction = Transaction.initialize_transaction(transaction_params)

        if transaction.save
          response_format(I18n.t('transactions.success'), { transaction_id: transaction.transaction_id }, :created)
        else
          response_format(I18n.t('transactions.error'), { errors: transaction.errors.full_messages },
                          :unprocessable_entity)
        end
      rescue StandardError => e
        response_format(I18n.t('transactions.error'), { errors: [e.message] }, :internal_server_error)
      end

      def bulk
        transaction_service = TransactionProcessingService.new(permitted_bulk_transactions)

        if permitted_bulk_transactions.size >= Transaction::BULKDATANUMBER
          process_large_batch
          # elsif
          # If the data size is very large, like 1 million records, we can handle batch processing in the background.
        else
          process_small_batch(transaction_service)
        end
      rescue StandardError => e
        response_format(I18n.t('transactions.error'), { errors: [e.message] }, :internal_server_error)
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
    end
  end
end
