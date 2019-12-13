require 'securerandom'

class Api::V1::ImageParserController < ApplicationController

  def begin_fetch
    request_id = SecureRandom.uuid
    FetchUrlWorker.perform_async(request_id, params["url"])

    render status: :ok, json: request_id.to_json
  end

  def get_fetched_url
    result = Redis.new.get(params["request_id"])
    render status: :ok, json: result
  end

end
