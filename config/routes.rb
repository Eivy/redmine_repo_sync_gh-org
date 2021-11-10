# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
get 'gh_webhook', to: 'gh_webhook#index'
post 'gh_webhook', to: 'gh_webhook#handler'
