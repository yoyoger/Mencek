class User < ApplicationRecord
  attr_accessor :remember_token
  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name: "Relationship",
                                  foreign_key: "follower_id",
                                  dependent: :destroy
  has_many :passive_relationships, class_name: "Relationship",
                                  foreign_key: "followed_id",
                                  dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower
  has_one_attached :icon
  before_save { self.email = email.downcase }
  validates :handle, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, length: { minimum:6 }, allow_nil: true
  validate :icon_type, :icon_size

  class << self
    # 渡された文字列のハッシュ値を返す
    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                    BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end

    # ランダムなトークンを返す
    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  # 永続セッションのためにユーザーをデータベースに記憶する
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # 渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  #ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end

  def feed
    Micropost.where("user_id IN (?) OR user_id = ?", following_ids, id).order(created_at: "DESC")
  end

  def follow(other_user)
    following << other_user
  end

  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  def following?(other_user)
    following.include?(other_user)
  end

  def icon_normal
    icon.variant(gravity: :center, resize:"100x100^", crop:"100x100+0+0").processed
  end

  def icon_small
    icon.variant(gravity: :center, resize:"50x50^", crop:"50x50+0+0").processed
  end

  private
    def icon_type
        if !icon.blob.content_type.in?(%('image/jpeg image/png'))
          errors.add(:icon, 'はjpegまたはpng形式でアップロードしてください')
        end
    end

    def icon_size
        if icon.blob.byte_size > 5.megabytes
          errors.add(:icon, "はサイズ5MB以内にしてください")
        end
    end
end
