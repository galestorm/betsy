class MerchantsController < ApplicationController
  def index
    @merchants = Merchant.all
  end

  def new
    @merchant = Merchant.new
  end

  def create
    @merchant = Merchant.new merchant_params
    if @merchant.save
      flash[:success] = "Successfully created new merchant!"
      redirect_to merchant_path(@merchant.id)
    else
      flash.now[:error] = "Could not create new merchant."
      render :new
    end
  end

  def show
    @merchant = Merchant.find( params[:id].to_i )
  end

  def edit
    @merchant = Merchant.find_by(id: params[:id].to_i)

    unless @merchant
      redirect_to root_path
    end
  end

  def update
    @merchant = Merchant.find_by(id: params[:id].to_i)
    redirect_to root_path unless @merchant

    if @merchant.update_attributes merchant_params
      redirect_to root_path
    else
      render :edit
    end
  end

  def destroy
    Merchant.find_by(id: params[:id]).destroy
    redirect_to root_path
  end

  private

  def merchant_params
    return params.require(:merchant).permit(:username, :email)
  end
end