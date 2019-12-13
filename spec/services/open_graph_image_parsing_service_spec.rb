RSpec.describe OpenGraphImageParsingService, type: :service do
  describe "OpenGraphImageParsingService" do
    it "parses an OpenGraph document's image's URL, width, and height attributes" do
      content = File.read("#{File.dirname(__FILE__)}/../fixtures/image_structured_attributes.html")
      service = OpenGraphImageParsingService.new(content)

      expect(service.url).to eql("http://example.com/ogp.jpg")
      expect(service.width).to eql("400")
      expect(service.height).to eql("300")
    end

    it "parses an OpenGraph document's image's URL even if the width and height attributes are absent" do
      content = File.read("#{File.dirname(__FILE__)}/../fixtures/image_structured_attributes_no_width_and_height.html")
      service = OpenGraphImageParsingService.new(content)

      expect(service.url).to eql("http://example.com/ogp.jpg")
      expect(service.width).to be_nil
      expect(service.height).to be_nil
    end

    it "throws a MissingAttributeError if the image URL attribute is absent" do
      content = File.read("#{File.dirname(__FILE__)}/../fixtures/image_structured_attributes_no_image.html")
      expect { OpenGraphImageParsingService.new(content) }.to raise_error(OGP::MissingAttributeError)
    end
  end
end
