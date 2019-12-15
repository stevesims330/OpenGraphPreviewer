RSpec.describe HttpService, type: :service do
  describe "HttpService" do
    it "raises an InvalidUrlException if provided URL is not a valid URL" do
      expect { HttpService.new("invalid_url>").get }.to raise_exception(InvalidUrlException)
    end

    it "adds 'https://' to the beginning of URL's that begin with neither 'http://' nor 'https://'" do
      service = HttpService.new("example.com")
      url = service.instance_variable_get(:@url)
      expect(url).to eql("https://example.com")
    end
  end
end
