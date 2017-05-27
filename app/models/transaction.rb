class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :merchant
  has_one :items, through: :merchant
end
