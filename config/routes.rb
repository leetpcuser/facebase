Facebase::Engine.routes.draw do
  resources :streams
  resources :campaigns

  resources :components do
    post 'preview', :on => :member
    post 'litmus_preview', :on => :member
    post 'direct_preview', :on => :member
  end

  #  -------------------------------------------- Admin functionality
  match "/contacts/email_search", :controller => :contacts, :action => :email_search
  resources :contacts # TODO limit this

  # Emails
  match "/emails/preview", :controller => :emails, :action => :preview
  match "/emails/fb_tester", :controller => :emails, :action => :fb_tester
  get "/emails", :controller => :emails, :action => :index
  get "/email_editor", :controller => :email_editor, :action => :index

  resources :shards
  resources :email_service_providers
  # --------------------------------------------- Tracking
  match "t", :controller => :tracking, :action => :link
  match "b", :controller => :tracking, :action => :bug
  match "a", :controller => :tracking, :action => :action
  match "u", :controller => :tracking, :action => :unsubscribe

  # --------------------------------------------- Reports
  #match "reports", :controller => :reports, :action => :campaigns
  #match "email", :controller => :reports, :action => :email

  # Sendgrid notification api
  post "sendgrid/notification", :controller => :sendgrid, :action => :notification

end
