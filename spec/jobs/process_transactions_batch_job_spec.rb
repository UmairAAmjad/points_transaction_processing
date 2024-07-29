# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProcessTransactionsBatchJob, type: :job do
  include ActiveJob::TestHelper

  let(:transaction_data) do
    [
      { 'transaction_id' => '12345', 'points' => 100, 'user_id' => '67890' },
      { 'transaction_id' => '67891', 'points' => 200, 'user_id' => '67892' }
    ]
  end

  describe '#perform' do
    it 'calls the TransactionProcessingService with the correct parameters' do
      service_instance = instance_double(TransactionProcessingService)
      allow(TransactionProcessingService).to receive(:new).with(transaction_data).and_return(service_instance)
      allow(service_instance).to receive(:process_batch).with(transaction_data)

      described_class.perform_now(transaction_data)

      expect(TransactionProcessingService).to have_received(:new).with(transaction_data)
      expect(service_instance).to have_received(:process_batch).with(transaction_data)
    end
  end

  describe 'enqueuing the job' do
    it 'enqueues the job' do
      expect do
        described_class.perform_later(transaction_data)
      end.to have_enqueued_job(described_class).with(transaction_data)
    end

    it 'enqueues the job in the default queue' do
      expect do
        described_class.perform_later(transaction_data)
      end.to have_enqueued_job.on_queue('default')
    end
  end
end
