class AdminController < ApplicationController

  def index
    @users = User.all
    @merchant_users = User.all.select{ |user| user.can_receive_payments?}
    @merchants = Merchant.where(user: @merchant_users )
  end

  def show
  end

  def edit

  end

  def update
    @user = User.find(params[:id])
    if params[:admin]
      @user.make_admin
      if @user.admin?
        redirect_to admin_index_path
      else
        redirect_to admin_index_path
      end
    end
    if params[:fee]
      @merchant.set_fee(params[:fee])
      @merchant.save
    end
  end

  def find_user
    @user = User.find(params[:user_id])
  end
end
