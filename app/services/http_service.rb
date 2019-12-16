class HttpService
  def initialize(url)
    @url = url
    unless url.starts_with?("http://") || url.starts_with?("https://")
      # HTTP gem requires a protocol; assume https if unspecified.
      @url = "https://#{url}"
    end
  end

  def get
    begin
      HTTP.follow.get(@url).to_s
    rescue HTTP::ConnectionError
      raise FailedConnectionException
    rescue Addressable::URI::InvalidURIError
      raise InvalidUrlException # For views that do not do client-side URL validation
    end
  end
end
