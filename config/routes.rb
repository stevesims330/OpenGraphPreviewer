Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get "open_graph_parser/begin_fetch" => "open_graph_parser#begin_fetch"
    end
  end
end
