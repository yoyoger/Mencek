class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token, :reset_token

  #ユーザと投稿　１対多
  has_many :microposts, dependent: :destroy

  #フォロー関係
  has_many :active_relationships, class_name: "Relationship",
                                  foreign_key: "follower_id",
                                  dependent: :destroy
  has_many :passive_relationships, class_name: "Relationship",
                                  foreign_key: "followed_id",
                                  dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower

  #食べたい・美味しかった
  has_many :markings
  has_many :want_eats, dependent: :destroy
  has_many :wanted_posts, through: :want_eats, source: :micropost
  has_many :recommends, dependent: :destroy
  has_many :recommended_posts, through: :recommends, source: :micropost

  #ActiveStorage
  has_one_attached :icon

  #バリデーション関連
  before_save :downcase_email
  # before_create :create_activation_digest

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

  # 渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  #ユーザーを有効化
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  #有効化トークンとダイジェストを作成及び代入する
  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end

  #有効化メールを送信
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  #パスワード再設定の属性を設定
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
  end

  #パスワード再設定メールを送信
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  #再設定トークンの有効期限
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  # 永続セッションのためにユーザーをデータベースに記憶する
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  #ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end

  def feed
    Micropost.where("user_id IN (?) OR user_id = ?", following_ids, id).order(created_at: "DESC")
  end

  #フォロー関連
  def follow(other_user)
    unless self == other_user
      following << other_user
    end
  end

  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  def following?(other_user)
    following.include?(other_user)
  end

  #食べたい関連
  def want_eat(micropost)
    want_eats.find_or_create_by(micropost_id: micropost.id)
  end

  def unwant_eat(micropost)
    want_eat = want_eats.find_by(micropost_id: micropost.id)
    want_eat.destroy if want_eat.present?
  end

  def want_eat?(micropost)
    wanted_posts.include?(micropost)
  end

  #おすすめ
  def recommend(micropost)
    recommends.find_or_create_by(micropost_id: micropost.id)
  end

  def unrecommend(micropost)
    recommend = recommends.find_by(micropost_id: micropost.id)
    recommend.destroy if recommend.present?
  end

  def recommend?(micropost)
    recommended_posts.include?(micropost)
  end

  #アイコンリサイズ
  def icon_normal
    icon.variant(gravity: :center, resize:"100x100^", crop:"100x100+0+0").processed
  end

  def icon_small
    icon.variant(gravity: :center, resize:"50x50^", crop:"50x50+0+0").processed
  end

  def icon_responsive
    icon.variant(gravity: :center, resize:"80x80^", crop:"80x80+0+0").processed
  end

  private
    def icon_type
      if icon.blob.present?
        if !icon.blob.content_type.in?(%('image/jpeg image/png'))
          errors.add(:icon, 'はjpegまたはpng形式でアップロードしてください')
        end
      end
    end

    def icon_size
      if icon.blob.present?
        if icon.blob.byte_size > 5.megabytes
          errors.add(:icon, "はサイズ5MB以内にしてください")
        end
      end
    end

    def downcase_email
      email.downcase!
    end
end
