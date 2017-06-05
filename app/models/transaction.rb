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

  def description(charge)
    "Transaction ID: #{id} -- #{user.email} just bought a #{item_bought.title} for $#{charge.to_s}, from #{merchant.title}"
  end

  def credit_in_cents
    (user.credit * 100).to_i
  end

  # Description inserted on charge that is covered by colo platform.
  # takes one arg which should be the total amount so we can visualise what portion of charge is covered.
  def credit_description(amount)
    "Credit Transaction where platform credit covers #{amount} of the original #{total_amount} for transaction ID: #{id} -- #{user.email} just bought a #{item_bought.title} for $#{total.to_s}, from #{merchant.title}"
  end

  def item_bought
    Item.find_by_id(self.item_id)
  end

  def charge_with_credit_check
    if user.credit?
      if credit_in_cents - total_amount < 0
        # The user has enough creidt to partially cover the fee
        customer_charge_after_deduction = total_amount - credit_in_cents

        # The portion of the charge the platform will cover
        platform_charge = total_amount - customer_charge_after_deduction

        # We now have to make two seperate charges
        # These charges are split between customer and platform
        # We do not charge a fee on the platform charge!
        make_charge(platform_charge, credit_description(platform_charge), ENV['MASTER_CREDIT_ACCOUNT'], 0, false)

        # The remainder that the customer must pay
        make_charge(customer_charge_after_deduction, description(customer_charge_after_deduction), user.stripe_customer_id, charged_fee, true)

        # Update user remaining credit to 0
        user.update_attribute(:credit, 0)
      else
        # The user has enough credit to cover the entire charge
        credit_remaining_after_deduction = user.credit - total_amount

        platform_charge = total_amount
        # Since the entire charge can be covered by credit
        # We only create one charge
        make_charge(platform_charge, charge_description(platform_charge), ENV['MASTER_CREDIT_ACCOUNT'], 0, false)

        # Update users remaining credit
        user.update_attribute(:credit, credit_remaining_after_deduction)
      end
    else
      # User has no credit so should be charged the full amount
      make_charge(total_amount, description(total_amount), user.stripe_customer_id, charged_fee, true)
    end
  end

  def make_charge(charge, customer, description, fee, regular_charge)
    charge = Stripe::Charge.create({
      # Total Amount user will be charged (in cents)
      amount: charge,
      # Currency of charge
      currency: 'USD',
      # the applicant users Stripe Customer ID
      # expect format of "cus_0xxXxXXX0XXxX0"
      customer: customer,
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
  byebug
  if charge.paid? && regular_charge?
    after_charge_succeeded(charge)
  end

  rescue => e
    errors.add(:stripe_charge_error, "Could not create the charge. Info from Stripe: #{e.message}")
  end

  def after_charge_succeeded(charge)
    update_attributes(paid: true, stripe_charge: charge.id, fee_charged: charged_fee/100) if charge.paid?
  end
end
