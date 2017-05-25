class MerchantsController < ApplicationController
  before_action :set_merchant, only: [:show, :edit, :update, :destroy]

  def index
    @user = current_user
    @merchants = Merchant.all
  end

  def show
  end

  def new
    @user = current_user
    @merchant = @user.merchants.build
  end

  def create
    @user = current_user
    @merchant = @user.merchants.new(merchant_params)

    if @merchant.save
      redirect_to merchants_path
    else
      format.html { render :new }
    end
  end

  def update
    if @merchant.save
      redirect_to merchants_path
    else
      format.html { render :new }
    end
  end

  def destroy
    @merchant.destroy
    respond_to do |format|
      format.html { redirect_to merchants_url, notice: 'Merchant was successfully destroyed.' }
    end
  end

  private

  def set_merchant
    @merchant = Merchant.find(params[:id])
  end

  def set_user
    @user = current_user
  end

  def merchant_params
    params.require(:merchant).permit(:title, :description, :user_id)
  end
end
