# frozen_string_literal: true

class CreateTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :transactions do |t|
      t.string :transaction_id, null: false
      t.integer :points, null: false
      t.string :user_id, null: false

      t.timestamps
    end

    add_index :transactions, :transaction_id, unique: true
  end
end
