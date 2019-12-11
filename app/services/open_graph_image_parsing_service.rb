class OpenGraphImageParsingService
  # I'm wrapping the parser gem in my own Service so that I can easily replace the parser if, say, the developer stops maintaining it.
  # If I called the gem directly and that happened, I'd have to replace it everywhere it's called. I'd also risk exposing parser
  # functionality that I don't want other developers to use, which would also make replacing it more difficult.
  #
  # I tried a few different names, like OpenGraphProcessingService, but decided upon OpenGraphImageParsingService. It tells other developers
  # that it's only processing OpenGraph's image attributes and allows me to use crisp, descriptive method names. Had I picked
  # OpenGraphProcessingService, I would have had to use reptitive method names like image_url(), image_width(), and image_height().
  def initialize(content)
    @image = OGP::OpenGraph.new(content).image
  end

  def url
    @image.url # A nil coalescing operator would be a no-op since the initializer throws a MissingAttributeError if there's no image URL.
  end

  def width
    @image&.width
  end

  def height
    @image&.height
  end
end
