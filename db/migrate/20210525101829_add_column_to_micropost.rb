class AddColumnToMicropost < ActiveRecord::Migration[6.1]
  def change
    add_column :microposts, :shop_name, :varchar(20)
    add_column :microposts, :menu_name, :varchar(20)
  end
end
