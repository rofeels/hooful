Rails.application.config.middleware.use OmniAuth::Builder do 
  provider :developer unless Rails.env.production?
  provider :twitter, TWITTER_KEY, TWITTER_SECRET
  provider :facebook, FACEBOOK_KEY, FACEBOOK_SECRET,{:scope => 'publish_stream,email,user_about_me,user_birthday,user_location,user_education_history,user_hometown', :display => 'popup'}
  OmniAuth.config.on_failure = UserController.action(:oauth_failure)
end