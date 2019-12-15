class FetchImageUrlWorker
  include Sidekiq::Worker

  def perform(website_url)
    # If an Open Graph image already exists for the website_url in Redis, return it instead of fetching it again.
    redis = Redis.new
    existing_result = redis.get(website_url)
    if existing_result
      image_url = JSON.parse(existing_result)["url"]
      return existing_result if image_url
    end

    result = { url: nil, error: nil }
    begin
      response_body = HttpService.new(website_url).get
      result[:url] = ImageParsingService.new(response_body).url
    rescue InvalidUrlException
      result[:error] = "Please enter a URL in the following format: https://www.example.com"
    rescue FailedConnectionException
      result[:error] = "Sorry, #{website_url} is currently unavailable. Please try again later."
    end

    if result[:url].nil? && result[:error].nil?
      result[:error] = "Sorry, #{website_url} is not a valid Open Graph document."
    end
    redis.set(website_url, result.to_json)
  end
end
