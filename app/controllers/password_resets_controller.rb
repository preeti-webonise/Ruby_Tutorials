class PasswordResetsController < ApplicationController
  before_action :getUser,   only: [:edit, :update]
  before_action :validUser, only: [:edit, :update]
  before_action :checkExpiration, only: [:edit, :update]    # Case (1)

  def new
  end

  def edit
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.createResetDigest
      @user.sendPasswordResetEmail
      flash[:info] = "Email sent with password reset instructions"
      redirect_to home_path
    else
      flash.now[:danger] = "Email address not found"
      render 'new'
    end
  end

  def update
    if params[:user][:password].empty?                  # Case (3)
      @user.errors.add(:password, "can't be empty")
      render 'edit'
    elsif @user.update_attributes(user_params)          # Case (4)
      log_in @user
      @user.update_attribute(:reset_digest, nil)
      flash[:success] = "Password has been reset."
      redirect_to @user
    else
      render 'edit'                                     # Case (2)
    end
  end

  private
  def user_params
  	params.require(:user).permit(:password, :password_confirmation)
	end

	def getUser
	@user = User.find_by(email: params[:email])
	end

	# Confirms a valid user.
	def validUser
		unless (@user && @user.activated? &&
		      @user.authenticated?(:reset, params[:id]))
			redirect_to home_path
		end
	end

 # Checks expiration of reset token.
  def checkExpiration
    if @user.passwordResetExpired?
      flash[:danger] = "Password reset has expired."
      redirect_to new_password_reset_url
    end
  end
end
