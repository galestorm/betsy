class AddProductDescriptionColumn < ActiveRecord::Migration[5.1]
  def change
    add_column :products, :description, :string
  end
end
