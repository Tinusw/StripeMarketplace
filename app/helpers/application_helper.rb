module ApplicationHelper
  def stripe_url
    "https://connect.stripe.com/oauth/authorize?response_type=code&client_id=#{ENV['CLIENT_ID']}&scope=read_write"
  end
end
