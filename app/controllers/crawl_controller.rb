class CrawlController < ApplicationController
  def parse
    url = params[:url]
    files, config = BaseParser.parse(url)
    if files
      render json: { images: files, config: config }
    else
      render json: { info: 'Do not find parser.' }, status: :bad_request
    end
  end

  def crawl
    images = params["images"]
    config = params["config"]
    images.each do |image|

    end
  end
end
