require 'rails_helper'

RSpec.describe BaseCrawler do
  before(:each) do
    @crawler = BaseCrawler.new
  end

  it 'should be able to get cookie path' do
    crawler_class = Class.new(BaseCrawler) do
      for_domain 'bing.com'
    end

    expect(crawler_class.new.cookie_path).to eq Rails.configuration.x.cookie_path.join('bing-com').to_s
  end

  it 'should get corresponding class for different domain' do
    class BingCrawler < BaseCrawler
      for_domain 'bing.com', dispatch_to: true
    end

    cclass = BaseCrawler.match_domain 'http://www.bing.com/'
    expect(cclass).to eq BingCrawler
  end

  it 'should be able to save and load cookies' do
    baidu_crawler = Class.new(BaseCrawler) do
      for_domain 'baidu.com'
    end
    @crawler = baidu_crawler.new

    @crawler.agent.get 'http://www.baidu.com'
    cookie_size = @crawler.agent.cookie_jar.cookies.size
    @crawler.save_cookies

    # now clear cookies
    @crawler.agent.cookie_jar.clear
    expect(@crawler.agent.cookie_jar.cookies.size).to eq 0

    # load them back
    @crawler.load_cookies
    expect(@crawler.agent.cookie_jar.cookies.size).to eq cookie_size
  end

  it 'can infer file extension from content-type' do
    @crawler.agent.get 'https://ss0.bdstatic.com/5aV1bjqh_Q23odCf/static/superman/img/logo_top_ca79a146.png'
    expect(@crawler.page.response['content-type']).to eq 'image/png'
    expect(@crawler.file_extension).to eq 'png'
  end
end
