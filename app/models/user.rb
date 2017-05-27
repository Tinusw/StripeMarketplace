class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

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
end
