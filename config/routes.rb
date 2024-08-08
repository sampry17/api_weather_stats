Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  namespace :api do
    namespace :v1 do
      get 'health', to: 'health#index'

      namespace :weather do
        get 'historical', to: 'weather#historical'
        get 'historical/max', to: 'weather#max'
        get 'historical/min', to: 'weather#min'
        get 'historical/avg', to: 'weather#avg'
        get 'current', to: 'weather#current'
        get 'by_time', to: 'weather#by_time'
      end
    end
  end
end
