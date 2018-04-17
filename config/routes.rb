Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'application#hello' #root is the redirection and controller#action
  get 'bye', to: 'application#bye' #get will be used ti get the rediection other than root
end
