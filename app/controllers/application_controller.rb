class ApplicationController < ActionController::Base
	def hello
		render html: "Hello, Welcome to rails" 
	end

	def bye
		render html: "Good bye"
	end
end
