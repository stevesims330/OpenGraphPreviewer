class HttpService
  # I wrapped the HTTP gem in a service for the same reason that I wrapped the OGP gem in one. app/services/image_parsing_service.rb
  # has a detailed explanation.
  def initialize(url)
    @url = url
    unless url.starts_with?("http://") || url.starts_with?("https://")
      # The HTTP gem throws an error if the protocol is missing, but it handles many other cases, like redirects. Thus, when the user
      # does not provide a protocol, it doesn't matter whether I prepend "http" or "https" as long as the prepended URL redirects if its
      # protocol is incorrect.
      @url = "https://#{url}"
    end
  end

  def get
    begin
      HTTP.follow.get(@url).to_s
    rescue HTTP::ConnectionError
      raise FailedConnectionException
    rescue Addressable::URI::InvalidURIError
      # Since I validate the URL clientside (so that the user has instantaneous feedback), this will rarely if ever occur. But it could if another developer
      # uses this service for a different view that doesn't validate the URL first.
      raise InvalidUrlException
    end
  end
end
