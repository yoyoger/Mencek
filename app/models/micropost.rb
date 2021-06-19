class Micropost < ApplicationRecord
  belongs_to :user

  has_many :want_eats, dependent: :destroy
  has_many :wanters, through: :want_eats, source: :user
  has_many :recommends, dependent: :destroy
  has_many :recommenders, through: :recommends, source: :user

  has_many_attached :pictures

  validates :user_id, presence: true
  validates :shop_name, presence: true, length: { maximum: 50 }
  validates :menu_name, presence: true, length: { maximum: 50 }
  validates :content, presence: true, length: { maximum: 255 }
  validate :picture_type, :picture_size, :picture_length

  private
    def picture_type
      pictures.each do |picture|
        if !picture.blob.content_type.in?(%('image/jpeg image/png'))
          errors.add(:pictures, 'はjpegまたはpng形式でアップロードしてください')
        end
      end
    end

    def picture_size
      pictures.each do |picture|
        if picture.blob.byte_size > 5.megabytes
          errors.add(:pictures, "は各ファイル5MB以内にしてください")
        end
      end
    end

    def picture_length
      if pictures.length > 3
        errors.add(:pictures, "は3枚以内にしてください")
      end
    end
end
