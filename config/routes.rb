Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get "image_parser/begin_fetch" => "image_parser#begin_fetch"
      get "image_parser/get_fetched_url" => "image_parser#get_fetched_url"
    end
  end
end
