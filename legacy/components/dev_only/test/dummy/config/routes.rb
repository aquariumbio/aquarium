Rails.application.routes.draw do

  mount DevOnly::Engine => "/dev_only"
end
