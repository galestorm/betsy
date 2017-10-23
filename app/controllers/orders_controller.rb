class OrdersController < ApplicationController
  before_action :find_order, only: [:show, :edit, :update]

  def index
    @orders = Order.all
  end

  def show
    unless @order
      redirect_to root_path, status: :not_found
    end
  end

  #Do we actually need a new action?
  def new
    @order = Order.new
  end

  def create
    create_order
    #see application controller

    # @order = Order.new
    # @order.status = "pending"
    #
    # if @order.save
    #   session[:order_id] = @order.id
    #   flash[:success] = "Order added successfully"
    #   redirect_to root_path
    # else
    #   flash[:error] = "Order couldn't be processed."
    #   render :new
    # end
  end

  def edit
    if !@order
      redirect_to root_path, status: :not_found
    elsif @order
      if @order.status == "complete"
        flash[:error] = "You cannot edit a complete order"
        redirect_to root_path
      end
    end
  end

  def update
    if !@order
      redirect_to root_path, status: :not_found
    elsif @order
      if @order.status == "complete"
        flash[:error] = "You cannot update a complete order"
        redirect_to root_path
      else
        @order.status = "complete"
        if @order.update_attributes order_params
          flash[:success] = "You successfully submitted your order!"
          session[:order_id] = nil
          redirect_to confirm_order_path(@order.id)
        else
          flash[:error] = "All fields are required to complete your order."
          render :edit, status: :bad_request
        end
      end
    end
  end

  private

  def order_params
    return params.require(:order).permit(:name, :address, :city, :state, :zip_code, :email, :card_number, :card_exp, :card_cvv)
  end

  def find_order
    @order = Order.find_by(id: params[:id])
  end

end
