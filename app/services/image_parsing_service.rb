class ImageParsingService
  # I'm wrapping the parser gem in my own Service so that I can easily replace the parser if, say, the developer stops maintaining it.
  # If I called the gem directly and that happened, I'd have to replace it everywhere it's called. I'd also risk exposing parser
  # functionality that I don't want other developers to use, which would also make replacing it more difficult.
  #
  # I tried a few different names, like OpenGraphProcessingService, but decided upon ImageParsingService. It tells other developers
  # that it's only processing OpenGraph's image attributes and allows me to use crisp, descriptive method names. Had I picked
  # OpenGraphProcessingService, I would have had to use reptitive method names like image_url(), image_width(), and image_height().
  def initialize(content)
    @image = nil
    begin
      @image = OGP::OpenGraph.new(content).image
    rescue OGP::MissingAttributeError => e
      # This error happens whenever the webpage content doesn't contain all of the mandatory Open Graph attributes, such as images, or any
      # webpage that doesn't have Open Graph attributes.
      #
      # While swallowing errors is usually harmful since it hides bugs, I expect OGP::MissingAttributeError to happen frequently, so
      # they're not really aberrant behavior for this application. Thus, I should not float them up.
      #
      # Also, if I did float it up, I'd expose the underlying ImageParsingService implementation, e.g. the ogp gem. If another developer
      # writes behavior that depends upon the service throwing an OGP::MissingAttributeError, swapping out the ogp gem would become that
      # much more difficult.
      #
      # Conversely, I do _not_ swallow generic errors on purpose. If one occurs, I want to see the stacktrace in Sentry so I can fix it.
    rescue OGP::MalformedSourceError => e
      # On the other hand, I don't expect OGP::MalformedSourceErrors to occur, at least not very often. The ogp gem only throws them if
      # the webpage does not include a closing </html> tag: https://github.com/jcouture/ogp/tree/5c5460a3f99b82ea18d4f1596fcb5f548b22e191/lib/ogp/open_graph.rb#L23.
      #
      # I chose to wrap OGP::MalformedSourceErrors in my own InvalidHtmlException to avoid exposing the ogp gem outside the ImageParsingService.
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
