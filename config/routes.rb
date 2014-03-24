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
  match ":username/katalog" => "catalogues#index", :as => "catalogue"  
  match "unauthorized_access" => "application#unauthorized_access"
  match "show_error" => "application#show_error"
  match "poruke" => "messages#index", :as => "messages"
  match "mobiteli" => "phones#index", :as => "phones"
  
  #TODO: check this
  devise_scope :account do    
    match "registracija" => "accounts/registrations#index", :as => "register", :via => :get
    match "registracija_korisnika" => "accounts/registrations#new", :account => { :type => "user" }, :as => "register_user"
    match "registracija_prodavnice" => "accounts/registrations#new", :account => { :type => "store" }, :as => "register_store"
    match "registracija" => "accounts/registrations#create", :as => "registration", :method => :post  
  
    # match "reset_password" => "devise/passwords#new", :as => "new_unlock", :method => :get
    # match "reset_password" => "devise/passwords#create", :as => "create_unlock", :method => :post
  end
  
  devise_for :accounts, :controllers => {
    :sessions => "accounts/sessions",
    :passwords => "devise/passwords"
  },
  :path => "",
  :path_names => {:sign_in => "prijava", :sign_out => "odjava", :new_unlock => "promijeni_sifru"}
  
  namespace :api do
    namespace :v1 do      
      match "chat/config" => "chat#get_conf", via: :get
      
      mount Api::V1::Phones, :at => "/mobiteli"
      mount Api::V1::Messages, :at => "/poruke"
      mount Api::V1::Catalogue, :at => "/katalog"
    end
  end
  
  namespace :admin do
    match "korisnici" => "users#list_users", :as => "users"
    match "users/lock" => "users#lock_user", via: :post
    
    resources :phones, :only => [:new, :edit, :create, :update, :destroy]
    match "phones/add/:id" => "phones#add", via: :post, :as => "phone_add"
    match "mobiteli" => "phones#list_phones", via: :get, :as => "phones"
    match "mobiteli/atributi" => "phones#attributes", via: :get, :as => "phones_attributes"
    match "phones_add_attribute" => "phones#add_attribute", via: :post
    match "mobiteli/import" => "phones#import_phones", via: :get
    match "phones/import" => "phones#import", via: :post, :as => "phones_import_phones"
    match "phones/import_images" => "phones#import_images", via: :post
    match "mobiteli/reindex" => "phones#reindex", via: :get, :as => "phones_reindex"
    
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
    
  match "/postavke" => "accounts#show", :as => "settings", :via => "get"
  match "/remove_settings" => "accounts#remove", :as => "settings_remove", :via => :delete
  match "/add_settings" => "accounts#add", :as => "settings_add", :via => :put
  match "/change_password" => "accounts#change_password", :as => "change_password", :via => :post
  match "/accounts_details" => "accounts#accounts_details", :as => "accounts_details", :via => :post  
  match "settings/change_avatar" => "accounts#change_avatar", :as => "change_avatar", :via => :post
 
  # match "/:brand" => "home#index", :as => "brand", :via => "get"
  match "mobiteli/:brand" => "phones#index", :as => "brand", :via => "get"
  
  mount Heartbeat::Application, :at => "/heartbeat"  
end
