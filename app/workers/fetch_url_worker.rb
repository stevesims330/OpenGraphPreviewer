class FetchUrlWorker
  include Sidekiq::Worker

  def perform(request_id)
    hello_world = "FetchUrlWorker.perform called. request_id: #{request_id}"
    Rails.logger.info(hello_world)
    puts hello_world
  end
end
