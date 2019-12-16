class Api::V1::ImageParserController < ApplicationController
  # Kicks off a job to fetch a website URL's Open Graph image URL. However, if that website already has an Open Graph
  # image URL, begin_fetch simply returns it.
  def begin_fetch
    FetchImageUrlWorker.perform_async(params["website_url"])

    render status: :no_content, json: "".to_json # axios turns a head: no_content into a 500
  end

  # Retrieves a website URL's Open Graph image URL from Redis.
  def retrieve_image_url
    result = Redis.new.get(params["website_url"])

    if result
      render status: :ok, json: result
    else
      # Return 404 if the job has not yet finished
      render status: :not_found, json: result.to_json
    end
  end
end
