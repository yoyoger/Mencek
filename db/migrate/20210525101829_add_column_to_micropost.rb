class AddColumnToMicropost < ActiveRecord::Migration[6.1]
  def change
    add_column :microposts, :shop_name, :string
    add_column :microposts, :menu_name, :string
  end
end
