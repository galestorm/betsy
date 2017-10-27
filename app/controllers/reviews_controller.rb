class ReviewsController < ApplicationController


  def new
    @product = Product.find_by(id: params[:product_id])
    @review = Review.new
  end

  def create
    puts params
    @review = Review.new(review_params)
    @review.product_id = params[:product_id]
    # @review.rating = @review.rating.to_i

    if @review.save
      flash[:status] = :success
      flash[:result_text] = "Successfully reviewed!"
      # redirect_to root_path
      redirect_to product_path(@review.product_id)
    else

      puts "the new model"
      puts @review
      puts @review.rating
      puts @review.text_review
      flash[:status] = :failure
      flash[:result_text] = "Could not review this product."
      flash[:messages] = @review.errors.messages
      render :new, status: :bad_request
    end
  end


  private

 def review_params
    params.require(:review).permit(:rating, :text_review)
 end
end
