class User < ActiveRecord::Base
  attr_accessor :remember_token, :activation_token, :reset_token
  has_many :microposts, dependent: :destroy
  before_save :downcase_email
  before_create :create_activation_digest
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
            format:           { with: VALID_EMAIL_REGEX },
            uniqueness:       { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  # return hash_value of literal is given
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # return random token
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # stores the user to the database to be used in permanent session
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # account activation!
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # send email for activation
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # setting for password reset
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
  end

  # send email for password reset
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # return true if the passed-in token matches the digest
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # login forgot
  def forget
    update_attribute(:remember_digest, nil)
  end

  # return if password reset expired
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  # test feed
  def feed
     Micropost.where('user_id = ?', id)
  end

  private

  # force update downcase for all email
  def downcase_email
    self.email = email.downcase
  end

  # acitivate token and digest create and assign
  def create_activation_digest
    self.activation_token  = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
