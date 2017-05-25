class MerchantsController < ApplicationController
  before_action :set_merchant, only: [:show, :edit, :update, :destroy]

  # GET /merchants
  # GET /merchants.json
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

  # DELETE /merchants/1
  # DELETE /merchants/1.json
  def destroy
    @merchant.destroy
    respond_to do |format|
      format.html { redirect_to merchants_url, notice: 'Merchant was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_merchant
      @merchant = Merchant.find(params[:id])
    end

    def set_user
      @user = current_user
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def merchant_params
      params.require(:merchant).permit(:title, :description, :user_id)
    end
end
