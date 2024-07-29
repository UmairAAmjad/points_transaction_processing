# frozen_string_literal: true

class TransactionProcessingService
  def initialize(transaction_params)
    @transaction_params = transaction_params
    @total_count = 0
    @errors = []
  end

  def process_in_batches(batch_size = 100)
    @transaction_params.each_slice(batch_size) do |transaction_data|
      process_batch(transaction_data)
    end

    { total_count: @total_count, errors: @errors }
  end

  def process_batch(transaction_data)
    ActiveRecord::Base.transaction do
      batch_transactions = build_transactions(transaction_data)
      batch_transactions.each do |transaction|
        process_transaction(transaction)
      end
    end
  end

  private

  def process_transaction(transaction)
    if save_transaction_with_retry(transaction)
      @total_count += 1
    else
      @errors << { transaction_id: transaction.transaction_id, errors: transaction.errors.full_messages }
      raise ActiveRecord::Rollback
    end
  end

  def build_transactions(transaction_params)
    transaction_params.map do |transaction_data|
      Transaction.new(transaction_data)
    end
  end

  def save_transaction_with_retry(transaction)
    max_retries = 3
    attempt_save(transaction, max_retries)
  end

  def attempt_save(transaction, max_retries)
    retries = 0
    begin
      transaction.save!
      true
    rescue ActiveRecord::RecordInvalid
      retries += 1
      retry if retries <= max_retries
      false
    end
  end
end
