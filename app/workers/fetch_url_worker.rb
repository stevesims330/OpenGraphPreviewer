class FetchUrlWorker
  include Sidekiq::Worker

  def perform(request_id, document_url)
    result = { :status => 200, :url => nil, error: nil }
    begin
      response = Faraday.get(document_url)
      result[:url] = ImageParsingService.new(response.body).url
    rescue Faraday::ConnectionFailed
      result[:status] = 400
      result[:error] = "Could not load #{document_url}. Perhaps the site is down or the URL is mistyped."
    end

    unless result[:url]
      result[:error] = "Not a valid Open Graph document." # In theory, it could have an og:image attribute but not some of the other mandatory attributes.
      result[:status] = 400
    end

    Redis.new.set(request_id, result)
    result
  end
end
