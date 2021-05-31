class Micropost < ApplicationRecord
  belongs_to :user
  validates :user_id, presence: true
  validates :shop_name, presence: true, length: { maximum: 50 }
  validates :menu_name, presence: true, length: { maximum: 50 }
  validates :content, presence: true, length: { maximum: 255 }
end
