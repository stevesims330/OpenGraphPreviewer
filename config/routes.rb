Rails.application.routes.draw do
  root 'open_graph_previewer#index'
  namespace :api do
    namespace :v1 do
      get "image_parser/begin_fetch" => "image_parser#begin_fetch"
      get "image_parser/retrieve_image_url" => "image_parser#retrieve_image_url"
    end
  end
end
