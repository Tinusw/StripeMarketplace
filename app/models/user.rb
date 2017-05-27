class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:stripe_connect]

  has_many :merchants, dependent: :destroy
  has_many :transactions

  def make_admin
    self.update_attributes!(admin: !admin)
  end

  def add_credit(amount)
    amount = BigDecimal.new(amount)
    new_total = credit + amount
    update_attributes!(credit: new_total)
  end

  def is_seller?
    merchants.any?
  end

  def can_receive_payments?
    uid? &&  provider? && access_code? && publishable_key?
  end

end
