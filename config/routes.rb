Mobis::Application.routes.draw do
  get "phone/new"
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
  
  devise_for :accounts, :controllers => { :registrations => "accounts/registrations", :sessions => "accounts/sessions" }
  devise_scope :account do
    match "registration" => "accounts/registrations#index", :as => "register"
    match "users/sign_up" => "accounts/registrations#new", :account => { :type => "user" }
    match "stores/sign_up" => "accounts/registrations#new", :account => { :type => "store" }
  end
  
  namespace :api do
    namespace :V1 do
      resources :phones
    end
  end
  
  resources :phones, :only => [:new, :create, :show]
  resources :comments do
    member do
      post "", :action => "create"
    end
    
    collection do
      get "new/:phone_id", :action => "new"
    end
  end
  
  resource :reviews do
    member do
      post "create_phone_review", :action => "create_phone_review"
    end
  end
  
  resource :catalogue, :only => [:new, :update, :edit] do
    match "pre_remove", :action => "pre_remove"
    match "remove", :action => "remove", via: :post
    match "phone_details_remote", :action => "phone_details_remote", via: :post
  end
  
  resource :search, :controller => "search" do
    collection do
      get "index"
      post "index"
      get "advanced_search"
      post "advanced_search"
    end
  end
   
  match ":username/catalogue" => "catalogues#index", :as => "catalogue"
  match "admin/users" => "users#list_users"
  match "admin/users/lock" => "users#lock_user", via: :post
  match "admin/phones" => "phones#list_phones"
  match "admin/phones/attributes" => "phones#attributes", via: :get
  match "admin/phones_add_attribute" => "phones#add_attribute", via: :post
  match "admin/phones/import_phones" => "phones#import_phones", via: :get
  match "admin/phones/import" => "phones#import", via: :post
  match "admin/phones/import_images" => "phones#import_images", via: :post   
  match "unathorized_access" => "application#unathorized_access"
  match "/:brand" => "home#index", :as => "brand"
end
