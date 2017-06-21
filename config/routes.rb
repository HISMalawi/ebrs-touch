Rails.application.routes.draw do
  get 'users/index'

  root 'person#index'

  get 'users/show'

  get 'users/view'

  get 'users/new'

  get 'users/create'

  get "/block_user/:id" => "users#block_user"

  get "/unblock_user/:id" => "users#unblock_user"

  get "/void_user/:id" => "users#void_user"

  get '/block'  => "users#block"

  get '/unblock' => "users#unblock"

  get '/query_users' =>"users#query_users"

  get "/view" => "person#view"

  get "/view_users" => "users#view"

  get 'users/my_account'

  post 'users/update_password'

  get 'users/change_password'

  get "/query" => "person#query"

  get "query_sync" =>"person#query_sync"


  get "/logout" => "logins#logout"

  get "/change_password" => "users#change_password"

  get "/login" => "logins#login"

  get "/search_by_fullname/:id" => "person#search_by_fullname"

  get "/search_by_name" => "person#search_by_name"

  get "/set_context/:id" => "logins#set_context"

  get "/edit_account" => "users#edit_account"

  get 'person/index'

  get 'person/show'

  get 'person/new'

  post 'person/create'

  post '/application/get_registration_type'

  get 'records/:status' => 'person#records'

  ########################### (create record form) routes

  get '/new_registration' => "dc#new_registration"

  post "/person/:id" => "person#show", :defaults => { :next_path => "view_record"}

  get '/get_last_names' => 'person#get_names', :defaults => {last_name: 'last_name'}
  get '/get_first_names' => 'person#get_names', :defaults => {first_name: 'first_name'}
  get '/search_by_nationality' => 'person#get_nationality'
  get '/search_by_country' => 'person#get_country'
  get '/search_by_district' => 'person#get_district'
  get '/search_by_ta' => 'person#get_ta'
  get '/search_by_village' => 'person#get_village'
  get '/search_by_hospital' => 'person#get_hospital'
  ########################### (create record form) routes end










  resources :person

  resources :users

  resource :login do
    collection do
      get :logout
    end
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
