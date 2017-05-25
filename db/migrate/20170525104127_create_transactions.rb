class CreateTransactions < ActiveRecord::Migration[5.0]
  def change
    create_table :transactions do |t|
      t.string :description
      t.references :user, foreign_key: true
      t.references :merchant, foreign_key: true

      t.timestamps
    end
  end
end
