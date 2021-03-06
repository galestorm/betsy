class ProductsController < ApplicationController
  before_action :find_product, only: [:show, :update, :destroy, :add_product_to_cart, :remove_product_from_cart]

  def index
    if params[:merchant_id]
      @merchant = Merchant.find_by(id: params[:merchant_id])
      if @merchant == nil
        flash[:status] = :failure
        flash[:result_text] = "Products for that merchant ID could not be found"
        redirect_to products_path, status: :not_found
      elsif @merchant.id == session[:user_id]
        @products = @merchant.products
      else
        @products = @merchant.products.where(available: "Available")
      end
    # elsif
    #   params[:review_id]
    #   @products = Review.where(product_id: params[:category_id])
    #   if @products == nil
    #     flash[:status] = :failure
    #     flash[:result_text] = "Products for that review ID could not be found"
    #     redirect_to products_path, status: :not_found
    #   end
    elsif
      params[:category_id]
      @category = Category.find_by(id: params[:category_id])
      if @category == nil
        flash[:status] = :failure
        flash[:result_text] = "Products for that category could not be found"
        redirect_to products_path, status: :not_found
      else
        @products = @category.products.where(available: "Available")
      end
    else
      @products = Product.all.where(available: "Available")
    end
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new product_params
    @product.merchant_id = session[:user_id]
    if @product.save
      flash[:status] = :success
      flash[:result_text] = "Successfully created your product!"
      redirect_to product_path(@product.id)
    else
      flash[:status] = :failure
      flash[:result_text] = "Could not create #{@product.name}."
      flash[:messages] = @product.errors.messages
      render :new, status: :bad_request
    end
  end

  def show
    find_product
    if @product == nil || @product.available == "Retired"
      flash[:status] = :failure
      flash[:result_text] = "That product is not available for viewing."
      redirect_to products_path, status: :not_found
    end
  end

  def edit
    @product = Product.find_by(id: params[:id])
    unless @product
      flash[:status] = :failure
      flash[:result_text] = "That product could not be found."
    end
  end

  def update
    if !@product
      redirect_to root_path, status: :not_found
    end

    category = Category.where(name: params[:product][:categories])
    @product.categories << category
    @product.save

    if @product.update_attributes product_params
      flash[:status] = :success
      flash[:result_text] = "Successfully updated product details!"
      redirect_to merchant_products_path(session[:user_id])
    else
      render :edit
    end
  end

  def destroy
    if !@product
      redirect_to root_path, status: :not_found
    elsif @product.destroy
      flash[:status] = :success
      flash[:result_text] = "Product deleted"
      redirect_to products_path
    else
      flash[:status] = :failure
      flash[:result_text] = "That product is unable to be deleted."
      redirect_to products_path, status: :not_found
    end
  end

  def add_product_to_cart
    @product = Product.find_by(id: params[:id])
    if @product.remove_one_from_stock
      if Order.find_by(id: session[:order_id]) == nil
        create_order
        order = Order.find_by(id: session[:order_id])
        order.products << @product
        order.save
        flash[:status] = :success
        flash[:result_text] = "product added to cart"
        redirect_to order_path(order.id)
      else
        order = Order.find_by(id: session[:order_id])
        order.products << @product
        order.save
        flash[:status] = :success
        flash[:result_text] = "product added to cart"
        redirect_to order_path(order.id)
      end
    else
      flash[:status] = :failure
      flash[:result_text] = "Product not available"
      redirect_back(fallback_location: products_path)
      # status :bad_request
    end
  end
  def remove_product_from_cart
    @product = Product.find_by(id: params[:id])
    order = Order.find_by(id: session[:order_id])
    if @product && order
      index_of_first_found = order.products.index {|element| element.id == @product.id}
      if index_of_first_found
        orders_products_array = order.products.to_a
        orders_products_array.delete_at(index_of_first_found)
        order.products.replace([])
        order.products.replace(orders_products_array)
        @product.add_one_to_stock
        flash[:status] = :success
        flash[:result_text] = "Successfully removed product from cart"
        redirect_to order_path(order.id)
      else
        flash[:status] = :failure
        flash[:result_text] = "Error: Product not found in cart"
      end
    end
  end

private
  def product_params
    params.require(:product).permit(:name, :price, :quantity_avail, :available, :photo, :description)
  end

  def find_product
    @product = Product.find_by(id: params[:id])
  end
end
