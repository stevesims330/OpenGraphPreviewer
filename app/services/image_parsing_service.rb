class ImageParsingService
  def initialize(content)
    @image = nil
    begin
      @image = OGP::OpenGraph.new(content).image
    # OGP::MissingAttributeError error happen whenever the webpage doesn't have Open Graph attributes. Thus, it's a very common
    # case for this application, so swallowing the error is acceptable here.
    rescue OGP::MissingAttributeError => e

    rescue OGP::MalformedSourceError => e
      raise InvalidHtmlException
    end
  end

  def url
    @image&.url
  end

  def width
    @image&.width
  end

  def height
    @image&.height
  end
end
