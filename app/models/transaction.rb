class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :merchant
  has_one :items, through: :merchant

  # The individual merchant fee converted to a percentage out of 100%
  def fee_as_percentage
    (merchant.fee * 100).to_i
  end

  # Total amount converted to cents
  def total_amount
    (total * 100).to_i
  end

  # Credit converted to cents
  def credit_in_cents
    (user.credit * 100).to_i
  end

  # Final fee in cents
  def charged_fee(amount)
    (amount * merchant.fee)
  end

  def description(amount)
    "#{user.email} just bought a #{item_bought.title} for $#{amount/100}, from #{merchant.title} for transaction ID: #{id}"
  end

  # Description inserted on charge that is covered by platform.
  def credit_description(amount)
    "Credited Transaction where platform credit covers $#{(amount/100)} of the original $#{total} for transaction ID: #{id} -- #{user.email} just bought a #{item_bought.title} for $#{total}, from #{merchant.title}"
  end

  def item_bought
    Item.find_by_id(self.item_id)
  end

  def charge_with_credit_check
    # User has no credit so should be charged the full amount
    make_charge(total_amount, user.stripe_customer_id, description(total_amount), charged_fee(total_amount), true) unless user.credit?

    # Check if user has credit
    if user.credit?
      # The user has enough credit to partially cover the total_amount
      if credit_in_cents - total_amount < 0
        customer_charge = total_amount - credit_in_cents
        platform_charge = total_amount - customer_charge
        # We now have to make two seperate charges
        make_charge(platform_charge, ENV['MASTER_CREDIT_ACCOUNT'], credit_description(platform_charge), 0, false)
        make_charge(customer_charge, user.stripe_customer_id, description(customer_charge), charged_fee(customer_charge), true)
        update_user_credit(0)
      else
        # The user has enough credit to cover the entire charge
        credit_remaining_after_deduction = user.credit - total_amount
        platform_charge = total_amount
        make_charge(platform_charge, ENV['MASTER_CREDIT_ACCOUNT'], credit_description(platform_charge), 0, false)
        update_user_credit(credit_remaining_after_deduction)
      end
    end
  end

  # If User has more than $1 left in credit, we update remainder
  def update_user_credit(amount)
    if amount > 1
      user.update_attribute(:credit, amount)
    else
      user.update_attribute(:credit, 0)
    end
  end

  def make_charge(charge, origin, description, fee, customer_payment)
    charge = Stripe::Charge.create({
      # Total Amount user will be charged (in cents)
      amount: charge,
      # Currency of charge
      currency: 'USD',
      # the origin of the charge
      # e.g. customers Stripe Customer ID
      # expect format of "cus_0xxXxXXX0XXxX0"
      customer: origin,
      # Description of charge
      description: description,
      # Final Destination of charge (host standalone account)
      # Expect format of acct_00X0XXXXXxxX0xX
      destination: merchant.user.uid,
      # Fee, set individually per merchant (as % but converted to cent)
      application_fee: fee.to_i
      }
    )
  # if the charge is successful, we'll receive a response in the charge object
  # We can then query that object via charge.paid
  # if true we can update our attribute
  if charge.paid?
    after_charge_succeeded(charge, fee) if charge_was_made_by_user(charge)
    after_credited_charge_succeeded(charge, fee) unless charge_was_made_by_user(charge)
  end

  rescue => e
    errors.add(:stripe_charge_error, "Could not create the charge. Info from Stripe: #{e.message}")
  end

  def charge_was_made_by_user(charge)
    return charge.customer == user.stripe_customer_id
  end

  def after_charge_succeeded(charge, fee)
    update_attributes(paid: true, stripe_charge: charge.id, fee_charged: (fee.to_i/100), total: charge.amount/100)
  end

  def after_credited_charge_succeeded(charge, fee)
    update_attributes(paid: true, stripe_charge: "credited purchase paid for by platform - #{charge.id}" , fee_charged: (fee.to_i/100), total: charge.amount/100)
  end
end
