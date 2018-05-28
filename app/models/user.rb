class User < ApplicationRecord
  attr_accessor :rememberToken, :activationToken, :resetToken
	before_save :downcaseEmail
  before_create :createActivationDigest
	has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name:  "Relationship",
                                  foreign_key: "follower_id",
                                  dependent:   :destroy
  has_many :passive_relationships,  class_name:  "Relationship",
                                    foreign_key: "followed_id",
                                    dependent:   :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower
  validates :name, presence: true, length: { maximum: 50 }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, presence: true, length: { maximum: 255}, 
					  format: { with: VALID_EMAIL_REGEX }
					  # uniqueness: { case_sensitive: false }
	has_secure_password
	validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

	# Returns the hash digest of the given string.
  def self.digest(string)
   	cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
   	BCrypt::Password.create(string, cost: cost)
  end

  # Returns a random token.
  def self.newToken
   	SecureRandom.urlsafe_base64
  end

  # Remembers a user in the database for use in persistent sessions.
	def remember
   	self.rememberToken = User.newToken
   	update_attribute(:remember_digest, User.digest(rememberToken))
  end

  # Returns true if the given token matches the digest.
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # Forgets a user.
  def forget
   	update_attribute(:remember_digest, nil)
  end

  # Activates an account.
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # Sends activation email.
  def sendActivationEmail
    UserMailer.account_activation(self).deliver_now
  end

  # Sets the password reset attributes.
  def createResetDigest
    self.resetToken = User.newToken
    update_columns(reset_digest: User.digest(resetToken), reset_sent_at: Time.zone.now)
  end

  # Sends password reset email.
  def sendPasswordResetEmail
    UserMailer.password_reset(self).deliver_now
  end

  # Returns true if a password reset has expired.
  def passwordResetExpired?
    reset_sent_at < 2.hours.ago
  end

  # Defines a proto-feed.
  # See "Following users" for the full implementation.
  def feed
    followingIds = "SELECT followed_id FROM relationships
                     WHERE  follower_id = :user_id"
    Micropost.where("user_id IN (#{followingIds})
                     OR user_id = :user_id", user_id: id)
  end

  # Follows a user.
  def follow(other_user)
    following << other_user
  end

  # Unfollows a user.
  def unfollow(other_user)
    following.delete(other_user)
  end

  # Returns true if the current user is following the other user.
  def following?(other_user)
    following.include?(other_user)
  end

  private
  # Creates and assigns the activation token and digest.
  def createActivationDigest
    self.activationToken  = User.newToken
    self.activation_digest = User.digest(activationToken)
  end

  # Converts email to all lower-case.
  def downcaseEmail
    email.downcase!
  end
end

			