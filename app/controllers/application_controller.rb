class ApplicationController < ActionController::Base
  before_action :assign_env_variable

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(resource)
    new_user_session_path
  end

  def assign_env_variable
    gon.stripe_key = ENV['PUBLISHABLE_KEY']
  end
end
