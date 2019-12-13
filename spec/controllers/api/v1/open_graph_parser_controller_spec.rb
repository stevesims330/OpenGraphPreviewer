describe Api::V1::OpenGraphParserController, "Routing", type: :controller do
  it { expect({ get: "api/v1/open_graph_parser/begin_fetch" }).to route_to({ action: "begin_fetch", controller: "api/v1/open_graph_parser" }) }
end
