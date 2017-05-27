class Merchant < ApplicationRecord
  belongs_to :user
  has_many :items
  has_many :transactions

  def owner
    user
  end
end
