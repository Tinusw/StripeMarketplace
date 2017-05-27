class RemoveDescriptionFromTransactions < ActiveRecord::Migration[5.0]
  def change
    remove_column :transactions, :description
  end
end
