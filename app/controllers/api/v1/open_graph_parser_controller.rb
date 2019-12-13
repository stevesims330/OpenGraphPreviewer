class Api::V1::OpenGraphParserController < ApplicationController

  #TODO(stevesims330): Make it so this doesn't block the thread by kicking it off into a job.

  # TODO(stevesims330): Most of this logic will go into a job. begin_fetch will merely kick off the job and return an ID.
  def begin_fetch
    begin
      response = Faraday.get(params["document_url"])
    rescue Faraday::ConnectionFailed
      return render status: :bad_request, json: "Could not load #{params["document_url"]}. Perhaps the site is down or the URL is mistyped."
    end

    begin
      image_url = OpenGraphImageParsingService.new(response.body).url
    rescue OGP::MalformedSourceError => e
      return render status: :bad_request, json: "No Open Graph og:image attribute found."
    end

    render status: :ok, json: image_url.to_json
  end

  # def get_fetched_url

end
