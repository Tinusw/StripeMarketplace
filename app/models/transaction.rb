class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :merchant
  has_many :transactions
end
