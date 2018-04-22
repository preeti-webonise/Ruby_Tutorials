class ApplicationController < ActionController::Base
	def hello
	    render html: "Hello, Welcome to Ruby!"
	end
end
