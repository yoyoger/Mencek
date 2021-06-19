class CreateMarkings < ActiveRecord::Migration[6.1]
  def change
    create_table :markings do |t|
      t.type 
      t.references :user, null: false, foreign_key: true
      t.references :micropost, null: false, foreign_key: true

      t.timestamps

      t.index [:user_id, :micropost_id, :type], unique: true
    end
  end
end
