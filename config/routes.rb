Rails.application.routes.draw do
  get 'workers/:id' => 'anemone/workers#show'
end
