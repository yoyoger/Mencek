class Micropost < ApplicationRecord
  belongs_to :user
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates :shop_name, presence: true
  validates :menu_name, presence: true
  validates :content, presence: true, length: { maximum: 255 }
end
