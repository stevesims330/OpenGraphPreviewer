describe Api::V1::ImageParserController, "Routing", type: :controller do
  it { expect({ get: "api/v1/image_parser/begin_fetch" }).to route_to({ action: "begin_fetch", controller: "api/v1/image_parser" }) }
  it { expect({ get: "api/v1/image_parser/retrieve_image_url" }).to route_to({ action: "retrieve_image_url", controller: "api/v1/image_parser" }) }
end

describe Api::V1::ImageParserController, "Actions" do
  describe "on #begin_fetch" do
    before do
      allow(FetchImageUrlWorker).to receive(:perform_async).and_return(true)
      get :begin_fetch, params: { format: :json }
    end

    it "returns a 204 when queuing FetchImageUrlWorker succeeds" do
      expect(response.status).to eq 204
    end
  end

  describe "on #retrieve_image_url" do
    it "returns a 200 when the provided website_url exists in Redis" do
      allow_any_instance_of(Redis).to receive(:get).and_return("{\"url\":\"http://example.com/image.png\",\"error\":null}")

      get :retrieve_image_url, params: { format: :json }
      expect(response.status).to eq 200
      image_url = JSON.parse(response.body)["url"]
      expect(image_url).to eq "http://example.com/image.png"
    end

    it "returns a 404 when the provided website_url does not exists in Redis" do
      allow_any_instance_of(Redis).to receive(:get).and_return(nil)

      get :retrieve_image_url, params: { format: :json }
      expect(response.status).to eq 404
    end
  end
end
