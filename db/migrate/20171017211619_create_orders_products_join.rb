class CreateOrdersProductsJoin < ActiveRecord::Migration[5.1]
  def change
    create_table :orders_products do |t|
      t.belongs_to :product, index: true
      t.belongs_to :order, index: true
    end
  end
end
