class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :merchant
  has_one :items, through: :merchant

  # The individual merchant fee converted to a percentage out of 100%
  def fee_as_percentage
    (merchant.fee * 100).to_i
  end

  def total_amount
    (total * 100).to_i
  end

  def charged_fee
    total_amount * merchant.fee
  end

  def description
    "Transaction ID: #{id} -- #{user.email} just bought a #{item_bought.title} for $#{total.to_s}, from #{merchant.title}"
  end

  def item_bought
    Item.find_by_id(self.item_id)
  end

  def make_charge
    charge = Stripe::Charge.create({
      # Total Amount user will be charged (in cents)
      amount: total_amount,
      # Currency of charge
      currency: 'USD',
      # the applicant users Stripe Customer ID
      # expect format of "cus_0xxXxXXX0XXxX0"
      customer: user.stripe_customer_id,
      # Description of charge
      description: description,
      # Final Destination of charge (host standalone account)
      # Expect format of acct_00X0XXXXXxxX0xX
      destination: merchant.user.uid,
      # Fee, set individually per merchant (as % but converted to cent)
      application_fee: charged_fee.to_i
      }
    )

  # if the charge is successful, we'll receive a response in the charge object
  # We can then query that object via charge.paid
  # if true we can update our attribute
  after_charge_succeeded(charge) if charge.paid?

  rescue => e
    errors.add(:stripe_charge_error, "Could not create the charge. Info from Stripe: #{e.message}")
  end

  def after_charge_succeeded(charge)
    update_attributes(paid: true, stripe_charge: charge.id, fee_charged: charged_fee/100) if charge.paid?
  end
end
