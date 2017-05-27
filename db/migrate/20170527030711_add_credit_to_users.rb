class AddCreditToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :credit, :decimal, precision: 8, scale: 2, default: 0.0, null: false
  end
end
