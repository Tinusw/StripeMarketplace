class AddItemIdToTransaction < ActiveRecord::Migration[5.0]
  def change
    add_column :transactions, :item_id, :integer
  end
end
