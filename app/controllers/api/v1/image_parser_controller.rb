require 'securerandom'

class Api::V1::ImageParserController < ApplicationController

  def begin_fetch
    request_id = SecureRandom.uuid
    FetchUrlWorker.perform_async(request_id, params["url"])

    render status: :ok, json: request_id.to_json
  end

  def get_fetched_url
    result = Redis.new.get(params["request_id"])

    if result
      render status: :ok, json: result
    else
      # There isn't a standard response for when a request succeeds, but the underlying backend operations have
      # not completed. While https://stackoverflow.com/a/27431829 is not the most upvoted answer, I think
      # a 404 is appropriate because the requested resource, e.g. the result Hash associated with the provided request_id,
      # quite literally does not exist yet.
      #
      # I considered using a status code that would let me use a Retry-After header as in https://www.geeksforgeeks.org/http-headers-retry-after/,
      # but the error codes don't describe what's happening very well. Also, Retry-After would add verbosity and complexity.
      # From the outset, I intended for the client to repeat requests but exponentially back-off each time.
      # So, the first request will occur 1 second after receieving a response with a nil URL, the second one
      # 2 seconds after, and so forth. If I used Retry-After, I'd have to keep track of how many seconds I'm backing
      # off in Redis.
      render status: :not_found, json: result.to_json
    end
  end

end
