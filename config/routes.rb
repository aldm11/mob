require "heartbeat/application"

Mobis::Application.routes.draw do
  get "home/new"
  get "home/index"
  get "home/about"
  get "home/contact"

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
  root :to => "home#index"
  
  match "set_js_vars" => "application#set_js_vars", :as => "set_js_vars", :via => :post
  match "get_js_var" => "application#get_js_var", :as => "get_js_var", :via => :post 
  match ":username/catalogue" => "catalogues#index", :as => "catalogue"  
  match "unauthorized_access" => "application#unauthorized_access"
  match "show_error" => "application#show_error"
  match "messages" => "messages#index"
  
  devise_for :accounts, :controllers => { :registrations => "accounts/registrations", :sessions => "accounts/sessions" }
  devise_scope :account do
    match "registration" => "accounts/registrations#index", :as => "register"
    match "users/sign_up" => "accounts/registrations#new", :account => { :type => "user" }
    match "stores/sign_up" => "accounts/registrations#new", :account => { :type => "store" }
  end
  
  namespace :api do
    namespace :v1 do      
      match "chat/config" => "chat#get_conf", via: :get
      
      mount Api::V1::Phones, :at => "/phones"
      mount Api::V1::Messages, :at => "/messages"
      mount Api::V1::Catalogue, :at => "/catalogue"
    end
  end
  
  namespace :admin do
    match "users" => "users#list_users"
    match "users/lock" => "users#lock_user", via: :post
    match "phones" => "phones#list_phones"
    match "phones/attributes" => "phones#attributes", via: :get
    match "phones_add_attribute" => "phones#add_attribute", via: :post
    match "phones/import_phones" => "phones#import_phones", via: :get
    match "phones/import" => "phones#import", via: :post
    match "phones/import_images" => "phones#import_images", via: :post
    
    resource :phones, :only => [:create, :new] 
  end
  
  resources :phones, :only => [:show]
  resources :comments, :only => [:create] do
    collection do
      match "show_next_page", :action => "show_next_page", :via => :post
      get "new/:phone_id", :action => "new"
    end
    member do
      post "", :action => "create"
    end
  end
  
  resource :reviews, :only => [] do
    member do
      post "create_phone_review", :action => "create_phone_review"
    end
  end
  
  resource :catalogue, :only => [:new, :update, :edit] do
    match "show_next_page", :action => "show_next_page", :via => :post
    match "pre_remove", :action => "pre_remove"
    match "remove", :action => "remove", via: :post
    match "phone_details_remote", :action => "phone_details_remote", via: :post
  end
  
  resource :message, :only => [:index, :new, :create, :update, :edit] do
    match "/:type/:id", :action => "show", :via => "get"
    match "show_next_page", :action => "show_next_page", :via => :post
    match "bulk_delete", :action => "bulk_delete", :via => :post
    match "receiver_id_remote", :action => "receiver_id_remote", :via => :post
    match "pre_remove", :action => "pre_remove", :via => "post"
    match "remove", :action => "remove", :via => "post"
    match "reply", :action => "reply", :via => "post"
  end
  
  resource :search, :only => [:index], :controller => "search" do
    collection do
      get "index"
      post "index"
      get "search_phones"
      post "search_phones"
      get "advanced_search"
      post "advanced_search"
    end
  end
  
  resource :account, :only => [:update, :destroy]
  
  match "/settings" => "accounts#show", :as => "settings", :via => "get"
  match "/accounts_details" => "accounts#accounts_details", :as => "accounts_details", :via => :post  
  match "/:brand" => "home#index", :as => "brand"
  
  mount Heartbeat::Application, :at => "/heartbeat"
end
