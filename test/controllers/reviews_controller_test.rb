require "test_helper"

describe ReviewsController do

  describe "new" do
    it "reviews" do
      get new_product_review_path(:product_id=>products(:pointy_hat).id)
      must_respond_with :success
    end
  end

  describe "create" do
    let(:merchant) { merchants(:spooky) }

    it "should be able to create a review" do
      proc{
        post product_reviews_path(products(:sad_hat).id), params: {review: {rating: 3, text_review: "Smokin."}  }
      }.must_change 'Review.count', 1

      must_respond_with :redirect
      must_redirect_to product_path(Review.last.product_id)
    end

   it "should rerender the form if it can't create the review" do
      proc   {
      post product_reviews_path(products(:sad_hat).id), params: { review: {rating: nil, text_review: "Smokin.", product_id: products(:pointy_hat).id}  }
    }.must_change 'Review.count', 0

        must_respond_with :bad_request
      end

    it "should prevent a merchant from creating a review on its products" do
      merchant = merchants(:spooky)
      login(merchant)
      proc {
        post product_reviews_path(products(:sad_hat).id), params: { review: {rating: 4, text_review: "buy this hat!", product_id: products(:sad_hat).id} }
      }.must_change 'Review.count', 0
    end
  end
end
