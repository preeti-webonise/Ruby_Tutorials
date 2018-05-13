class User < ApplicationRecord
  attr_accessor :rememberToken, :activationToken
	before_save :downcaseEmail
  before_create :createActivationDigest
	has_many :posts
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
  def authenticated?(rememberToken)
	  return false if remember_digest.nil?
      BCrypt::Password.new(remember_digest).is_password?(rememberToken)
  end

  # Forgets a user.
  def forget
   	update_attribute(:remember_digest, nil)
  end

  private
  # Creates and assigns the activation token and digest.
  def create_activation_digest
    self.activation_token  = User.new_token
    self.activation_digest = User.digest(activation_token)
  end

  # Converts email to all lower-case.
  def downcase_email
    self.email = email.downcase
  end
end

			