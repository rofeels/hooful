Hooful_test::Application.routes.draw do

  get "meet/update"
  get "home/index"
  get "home/search"

  root :to => 'home#intro'

  match '/intro' => 'home#intro'
  match '/home' => 'home#index'
  match '/test' => 'home#test'
  match '/fbtest' => 'home#fbtest'
  match '/search/(:keyword)' => 'home#search'
  match '/user' => 'user#show'
  get '/user/edit' => 'user#update'
  match '/user/edit/certification' => 'user#update_certification'
  get '/user/edit/password' => 'user#update_password'
  get '/user/edit/sns' => 'user#update_sns'
  get '/user/edit/notification' => 'user#update_notification'
  get '/user/edit/category' => 'user#update_category'
  post '/user/edit' => 'user#update_info'
  get '/user/ticket' => 'user#ticket'
  get '/user/ticket/old' => 'user#ticket_old'
  get '/user/ticket/reserved' => 'user#ticket_reserved'
  post '/user/ticket/cancel' => 'user#ticket_cancel_create'
  get '/user/ticket/:tid/cancel' => 'user#ticket_cancel'
  get '/user/ticket/:tid/print' => 'user#ticket_print'
  get '/user/ticket/:tid' => 'user#ticket_detail'
  match '/user/order' => 'user#order'
  get '/user/order/:orderid' => 'user#order_detail'
  post '/user/order/:orderid' => 'user#order_detail_cancel'
  match '/user/reset_password' => 'user#reset_password'
  match '/user/change_password' => 'user#change_password'
  match '/user/:userid' => 'user#show', :constraints  => { :userid => /[0-z\.]+/ }
  match '/signin' => 'user#index'
  match '/auth/:provider/callback' => 'user#callback'
  match '/welcome' => 'user#signup'
  match '/signup' => 'signup#step1'

  match '/signout' => 'user#signout'
  match '/support' => 'support#index'
  match '/support/terms' => 'support#terms'
  match '/support/privacy' => 'support#privacy'
  match '/notification' => 'notification#list'
  match '/c/:mCategory' => 'meet#community'

  #review
  match '/r/:rid' => 'review#show'
  match '/r' => 'review#index'
  match '/rwrite' => 'review#rwrite'
  #hope
  match '/h/:rid' => 'hope#show'
  match '/h' => 'hope#index'
  match '/hwrite' => 'hope#hwrite'
  #grouptalk
  match '/g/:gid' => 'group#show'


  #pay
  match '/payment' => 'pay#payment'
  match '/paysuccess' => 'pay#paysuccess'
  
  #log
  match '/log/Pageview' => 'log#Pageview'
  match '/log/Loadtime' => 'log#Loadtime'
  match '/log/Endtime' => 'log#Endtime'

  #meet
  match '/meet/create' => 'meet#create'
  match '/meet/subscription' => 'meet#subscription'
  match '/:mCode/edit' => 'meet#update'
  match '/:mCode/reservation' => 'meet#reservation'
  match '/:mCode/reservation/:tCode' => 'meet#reservation'
  match '/:mCode' => 'meet#index'
  match '/meet/manage' => 'meet#show'
  match '/meet/manage/withdraw' => 'meet#withdraw'
  match '/meet/:mCode' => 'meet#show'

  #mypeople
  match '/api/mypeople' => 'api#mypeople'


  scope 'api' do 
	resources :interest, :group, :hoopartice, :group_talk, :meet_group_talk, :ticket, :notification, :meetcmt, :reviewcmt, :community_talk, :review, :hope, :hopecmt, :guestbook, :withdraw, :tohooful, :community_document, :pay#, :model_name
  end

  match ':controller/:action(/:id)'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
