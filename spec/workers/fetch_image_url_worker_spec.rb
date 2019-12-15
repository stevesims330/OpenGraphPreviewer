describe FetchImageUrlWorker, type: :worker do
  before do
    @website_url = "http://dawawadwghkgjsks.com"
    @image_url = "#{@website_url}/image.png"
    @result_with_url = "{\"url\":\"#{@image_url}\",\"error\":null}"
    @result_with_error = "{\"url\":null,\"error\":\"Error message\"}"

    image_parsing_service_double = double
    image_parsing_service_double.stub(:url) { @image_url }

    content = File.read("#{File.dirname(__FILE__)}/../fixtures/image_structured_attributes.html")
    ImageParsingService.stub(:new).with(content).and_return(image_parsing_service_double)
    HttpService.any_instance.stub(:get).and_return(content)
  end

  before(:each) do
    Redis.new.del(@website_url)
  end

  it "does not refetch a website's Open graph image if Redis already has a result with an image URL for that website" do
    Redis.new.set(@website_url, @result_with_url)

    expect_any_instance_of(HttpService).to_not receive(:get)
    FetchImageUrlWorker.new.perform(@website_url)
  end

  it "fetches and caches a website's Open graph image if Redis does not already have a result for that website" do

    expect_any_instance_of(HttpService).to receive(:get)
    FetchImageUrlWorker.new.perform(@website_url)
    result = Redis.new.get(@website_url)
    expect(result).to eq @result_with_url
  end

  it "fetches and caches a website's Open graph image if Redis has an existing result with an error (and therefore without an image_url) for that website" do
    Redis.new.set(@website_url, @result_with_error)
    error_result = Redis.new.get(@website_url)
    expect(error_result).to eq @result_with_error

    expect_any_instance_of(HttpService).to receive(:get)
    FetchImageUrlWorker.new.perform(@website_url)
    result = Redis.new.get(@website_url)
    expect(result).to eq @result_with_url
  end
end
