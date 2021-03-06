require "test_helper"

describe Product do

  describe "validations" do
    it "requires a name" do
      products(:pointy_hat).merchant = Merchant.first
      products(:pointy_hat).save
      products(:pointy_hat).valid?.must_equal true


      products(:missing_name).merchant = Merchant.first
      products(:missing_name).save
      products(:missing_name).valid?.must_equal false

      products(:missing_name).name = "Another pointy hat"
      products(:missing_name).save
      products(:missing_name).valid?.must_equal true
    end

    it "requires a price" do
      test = Product.new(name: "Caldroun", quantity_avail: 1, merchant: Merchant.first)
      test.valid?.must_equal false

      test.price = 59.99
      test.valid?.must_equal true
    end

    it "requires a price that is a number" do
      test = Product.new(name: "Caldroun", quantity_avail: 1, price: "cats", merchant: Merchant.first)
      test.valid?.must_equal false
    end

    it "requires a price that is greater than 0" do
      test = Product.new(name: "Caldroun", quantity_avail: 1, price: -2.50, merchant: Merchant.first)
      test.valid?.must_equal false

      another = Product.new(name: "Caldroun", quantity_avail: 1, price: 0, merchant: Merchant.first)
      another.valid?.must_equal false
    end

    it "requires a quantity_avail" do
      test = Product.new(name: "Caldroun", price: 68.50, merchant: Merchant.first)
      test.valid?.must_equal false

      test.quantity_avail = 1
      test.valid?.must_equal true
    end

    it "can have a quantity_avail of 0" do
      test = Product.new(name: "Caldroun", quantity_avail: 0, price: 68.50, merchant: Merchant.first)
      test.valid?.must_equal true
    end

    it "cannot have a quantity_avail less than 0" do
      test = Product.new(name: "Caldroun", quantity_avail: -1, price: 68.50, merchant: Merchant.first)
      test.valid?.must_equal false
    end
  end

  describe "relations" do
    it "has a merchant" do
      test = Product.create(name: "Caldroun", quantity_avail: 5, price: 68.50, merchant: Merchant.first)
      test.merchant.must_equal Merchant.first

      test.merchant.id.must_equal Merchant.first.id
    end

    it "cannot exist without a merchant" do
      test = Product.create(name: "Caldroun", quantity_avail: 5, price: 68.50, merchant: nil)

      assert_nil(test.merchant, msg = nil)
      assert_nil(test.id, msg = nil)
    end

    it "has reviews" do
      test = Product.create(name: "Caldroun", quantity_avail: 5, price: 68.50, merchant: Merchant.first)
      review = Review.create(rating: 5, text_review: "This was better than my cast iron pan!", product_id: test.id)
      test.reviews.must_include review
      test.reviews[0].must_be_kind_of Review
      test.must_respond_to :reviews
    end

    it "has a list of orders it is in" do
      order = orders(:pending_order)
      product = products(:pointy_hat)

      product.must_respond_to :orders
      product.orders << order
      product.orders.count.must_equal 1
    end

    it "has categories" do
      product = products(:pointy_hat)

      product.must_respond_to :categories
    end

  end

  describe "#remove_one_from_stock" do
    it "should change product.quantity_avail" do
      product = products(:pointy_hat)

      proc {
        product.remove_one_from_stock
      }.must_change "product.quantity_avail", - 1
    end

    it "returns true if successful" do
      product = products(:pointy_hat)
      product.remove_one_from_stock.must_equal true
    end

    it "should not change product quantity if product isn't available" do
      product = products(:out_of_stock)

      proc {
        product.remove_one_from_stock
      }.wont_change "product.quantity_avail"
    end
    it "returns false if unsuccessful" do
      product = products(:out_of_stock)
      product.remove_one_from_stock.must_equal false
    end

  end
  describe "#add_one_to_stock" do
    it "should change product.quantity_avail" do
      product = products(:out_of_stock)

      proc {
        product.add_one_to_stock
      }.must_change "product.quantity_avail", 1
    end
    it "should return true if successful" do
      product = products(:out_of_stock)

      product.add_one_to_stock.must_equal true
    end
  end
  describe "average_rating" do
    it "can calculate an averate rating" do
      test = Product.create(name: "Caldroun", quantity_avail: 5, price: 68.50, merchant: Merchant.first)
      review = Review.create(rating: 1, text_review: "This was better than my cast iron pan!", product_id: test.id)
      review2 = Review.create(rating: 3, text_review: "This was better than my cast iron pan!", product_id: test.id)

      test.average_rating.must_equal 2
    end

    it "Returns 'not yet rated' if no reviews" do
      test = Product.create(name: "Caldroun", quantity_avail: 5, price: 68.50, merchant: Merchant.first)

      test.average_rating.must_equal "Not yet rated!"
    end

    it "doesn't break if review is nil" do
      test = Product.create(name: "Caldroun", quantity_avail: 5, price: 68.50, merchant: Merchant.first)
      review = Review.create(rating: nil, text_review: "eh", product_id: test.id)
      review = Review.create(rating: 3, text_review: "eh", product_id: test.id)

      test.average_rating.must_equal 3

    end
  end

end
