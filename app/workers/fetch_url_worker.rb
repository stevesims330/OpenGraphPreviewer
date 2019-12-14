class FetchUrlWorker
  include Sidekiq::Worker

  def perform(request_id, document_url)
    result = { url: nil, error: nil }
    # TODO(stevesims330): https//ogp.me/, https://ogp.me/, https://www.ogp.me/, and https://www.ogp.me/ should all return the same result
    begin
      response = Faraday.get(document_url)
      result[:url] = ImageParsingService.new(response.body).url
    rescue Faraday::ConnectionFailed
      # I wrote cheerful error messages on purpose: https://uxplanet.org/how-to-write-good-error-messages-858e4551cd4
      result[:error] = "Sorry, #{document_url} is currently unavailable. Please try again later."
    end

    # Instead of "if result[:url].nil? && result[:error].nil?", I originally had "unless result[:url] && result[:error]" here.
    # However, I reread it and it felt like a bit of a mental pretzel.
    if result[:url].nil? && result[:error].nil?
      result[:error] = "Sorry, #{document_url} is not a valid Open Graph document."
    end
    Redis.new.set(request_id, result.to_json)
  end
end
