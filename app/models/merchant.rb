class Merchant < ApplicationRecord
  belongs_to :user
  has_many :items
end
