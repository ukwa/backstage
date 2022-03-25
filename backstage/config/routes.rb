Rails.application.routes.draw do
 # Set-up optional prefix
 scope ENV['DEPLOY_RELATIVE_URL_ROOT'] || '/' do

  mount Blacklight::Engine => '/'
  concern :marc_viewable, Blacklight::Marc::Routes::MarcViewable.new
  concern :searchable, Blacklight::Routes::Searchable.new
  concern :exportable, Blacklight::Routes::Exportable.new
  root to: "mementos#index"

  devise_for :users

  # TrackDB
  scope '/trackdb' do
    resource :catalog, only: [:index], as: 'trackdb', path: '/', controller: 'trackdb', constraints: { id: /.+/ } do
      concerns :searchable
    end

    # No format guessing as extensions are part of the IDs, see https://stackoverflow.com/a/57895695
    #resources :solr_documents, only: [:show], path: '/trackdb', controller: 'trackdb', constraints: { id: /.+/ }, format: false, defaults: {format: 'text/html'} do
    resources :solr_documents, only: [:show], path: '/', controller: 'trackdb', constraints: { id: /.+/, format: false } do
      concerns :exportable
    end
  end

  # Mementos
  scope '/mementos' do
    resource :catalog, only: [:index], as: 'mementos', path: '/', controller: 'mementos', constraints: { id: /.+/ } do
      concerns :searchable
    end

    resources :solr_documents, only: [:show], path: '/', controller: 'mementos', constraints: { id: /.+/, format: false } do
      concerns :exportable
    end
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
