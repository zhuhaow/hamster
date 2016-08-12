class FileCrawler < BaseCrawler
  include Sidekiq::Worker

  def start
    start_download
  end

  def download_file_to_local(url)
    agent.get(url)

    to_path = temp_path
    FileUtils.mkdir_p to_path

    dest = File.join(to_path, filename)
    page.save dest unless File.exist? dest
    dest
  end

  def start_download
    local_file = download_file_to_local @url
    @config.upload_to.adapter.upload(local_file)
  end

  def load_cookies(cookie_name = nil)
    super if cookie_name
  end

  def temp_path
    super().join 'files'
  end
end
