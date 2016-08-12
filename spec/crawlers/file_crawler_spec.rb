require 'rails_helper'

RSpec.describe FileCrawler do
  before(:each) do
    @url = 'http://tb.himg.baidu.com/sys/portrait/item/fc2e3931353039393233376609'
  end

  it 'should be able to download image' do
    crawler = FileCrawler.new
    path = crawler.download_file_to_local @url
    expect(File.exist? path).to be true
    FileUtils.rm path
  end

  it 'downloads and uploads files' do
    upload_to = UploadConfig.new(GoogleDriveAdapter, remote_path: 'temp/google_drive_file_test')
    config = { upload_to: upload_to }
    crawler = FileCrawler.new
    crawler.perform(@url, config)
    expect(GoogleDrive.new.exists?('temp/google_drive_file_test')).to be true
  end
end
