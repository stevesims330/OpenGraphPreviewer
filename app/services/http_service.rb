class HttpService
  # I wrapped the HTTP gem in a service for the same reason that I wrapped the OGP gem in one. app/services/image_parsing_service.rb
  # has a detailed explanation.
  def initialize(url)
    @url = url
    unless url.starts_with?("http://") || url.starts_with?("https://")
      # The HTTP gem throws an error if the protocol is missing, but it handles many other cases, like redirects. Thus, when the user
      # does not provide a protocol, it doesn't matter whether I prepend "http" or "https" as long as the prepended URL redirects if it's
      # the wrong one.
      @url = "https://#{url}"
    end
  end

  def get
    begin
      HTTP.follow.get(@url).follow.to_s
    rescue HTTP::ConnectionError
      raise FailedConnectionException
    rescue Addressable::URI::InvalidURIError
      raise InvalidUrlException
    end
  end
end
