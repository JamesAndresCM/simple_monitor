Rails.application.routes.draw do


  get '/', to: redirect('v1/main')

  namespace :v1 do
    scope controller: :nethogs do
      get 'nethogs/search_nethogs_traffic' => :search_nethogs_traffic
      get 'nethogs/index' => :index
    end

    scope controller: :main do
      get '/' , to: redirect('v1/main')
      get 'main' => :index
    end

    scope controller: :iptraff do
      get 'iptraff/search_iptraf_traffic' => :search_iptraf_traffic
      get 'iptraff/index' => :index
    end

    scope controller: :httpd do
      get 'httpd/search_log_httpd' => :search_log_httpd
      get 'httpd/index' => :index
    end
  end

  match '*unmatched_route', :to => 'v1/errors#routing', via: [:all]

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
