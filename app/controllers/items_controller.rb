class ItemsController < ApplicationController

  def index
    @items = Item.all
  end

  def show
  end

  def new
    @merchant = Merchant.find(params[:merchant_id])
    @item = @merchant.items.build
  end

  def edit
    @merchant = Merchant.find(params[:merchant_id])
    @item = Item.find(params[:id])
  end

  def create
    @merchant = Merchant.find(params[:merchant_id])
    @item = @merchant.items.new(item_params)

    if @item.save
      redirect_to merchant_path(@merchant)
    else
      format.html { render :new }
    end
  end

  def update
    set_item
    @merchant = Merchant.find(params[:merchant_id])
    if @item.update(item_params)
      redirect_to merchant_path(@merchant)
    else
      format.html { render :edit }
    end
  end

  def destroy
    set_item
    @merchant = Merchant.find(params[:merchant_id])
    @item.destroy
    if @item.destroyed?
      redirect_to merchant_path(@merchant)
    else
      redirect_to merchant_path(@merchant)
    end
  end

  private

  def set_item
    @item = Item.find(params[:id])
  end

  def set_merchant
    @merchant = Merchant.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:title, :description, :price, :merchant_id)
  end
end
