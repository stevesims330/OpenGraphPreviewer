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
    rescue OGP::MalformedSourceError => e
      result[:status] = 400
      result[:error] = "No Open Graph og:image attribute found."
    end

    #TODO(stevesims330): Write a Redis config file
    Redis.new.set(request_id, result)
    result
  end
end
