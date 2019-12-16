RSpec.describe ImageParsingService, type: :service do
  describe "ImageParsingService" do
    it "parses an OpenGraph document's image's URL, width, and height attributes" do
      content = File.read("#{File.dirname(__FILE__)}/../fixtures/image_structured_attributes.html")
      service = ImageParsingService.new(content)

      expect(service.url).to eql("http://example.com/ogp.jpg")
      expect(service.width).to eql("400")
      expect(service.height).to eql("300")
    end

    it "parses an OpenGraph document's image's URL even if the width and height attributes are absent" do
      content = File.read("#{File.dirname(__FILE__)}/../fixtures/image_structured_attributes_no_width_and_height.html")
      service = ImageParsingService.new(content)

      expect(service.url).to eql("http://example.com/ogp.jpg")
      expect(service.width).to be_nil
      expect(service.height).to be_nil
    end

    it "returns nil attributes if the required image URL attribute is absent" do
      content = File.read("#{File.dirname(__FILE__)}/../fixtures/image_structured_attributes_no_image.html")
      service = ImageParsingService.new(content)

      expect(service.url).to be_nil
      expect(service.width).to be_nil
      expect(service.height).to be_nil
    end

    it "raises an InvalidHtmlException if the document is missing an </html> closing tag" do
      content = File.read("#{File.dirname(__FILE__)}/../fixtures/invalid_webpage.html")
      expect { ImageParsingService.new(content) }.to raise_exception(InvalidHtmlException)
    end
  end
end
