class Merchant < ApplicationRecord
  belongs_to :user
  has_many :items
  has_many :transactions

  def owner
    user
  end

  def set_fee(amount)
    update_attribute(:fee, amount)
  end
end
