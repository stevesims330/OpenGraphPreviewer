describe Api::V1::ImageParserController, "Routing", type: :controller do
  it { expect({ get: "api/v1/image_parser/begin_fetch" }).to route_to({ action: "begin_fetch", controller: "api/v1/image_parser" }) }
end
