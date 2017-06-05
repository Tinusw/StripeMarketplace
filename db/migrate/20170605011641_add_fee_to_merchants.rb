class AddFeeToMerchants < ActiveRecord::Migration[5.0]
  def change
    add_column :merchants, :fee, :decimal, {:precision=>5, :scale=>4, :default=>0.0}
    add_column :transactions, :fee_charged, :decimal, {:precision=>5, :scale=>4, :default=>0.0}
  end
end
