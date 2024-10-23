Rails.application.routes.draw do
  resources :ridings, only: [:index, :show] do
    resources :polling_locations, only: [:index] do
      collection do
        patch :update
      end
    end
  end

  root "ridings#index"
end
