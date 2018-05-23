class StaticPagesController < ApplicationController
  def home
  	# render html: "Welcome to homepage"
		if logged_in?
      @micropost  = current_user.microposts.build
      @feedItems = current_user.feed.paginate(page: params[:page])
    end
  end

  def help
  end

  def about
  end
end
