Rails.application.routes.draw do
 # Set-up optional prefix
 scope ENV['DEPLOY_RELATIVE_URL_ROOT'] || '/' do

  mount Blacklight::Engine => '/'
  concern :marc_viewable, Blacklight::Marc::Routes::MarcViewable.new
  root to: "catalog#index"
  concern :searchable, Blacklight::Routes::Searchable.new

  # TrackDB

  resource :trackdb, only: [:index], as: 'trackdb', path: '/trackdb', controller: 'trackdb', constraints: { id: /.+/ } do
    concerns :searchable
  end
  concern :exportable, Blacklight::Routes::Exportable.new

  # No format guessing as extensions are part of the IDs, see https://stackoverflow.com/a/57895695
  resources :solr_documents, only: [:show], path: '/trackdb', controller: 'trackdb', constraints: { id: /.+/ }, format: false, defaults: {format: 'html'}, do
    concerns :exportable
  end

  # Catalog

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog', constraints: { id: /.+/ } do
    concerns :searchable
  end
  devise_for :users
  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog', constraints: { id: /.+/ } do
    concerns [:exportable, :marc_viewable]
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end
 end
 # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
