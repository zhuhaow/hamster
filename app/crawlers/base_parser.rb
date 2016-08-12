class BaseParser < BaseCrawler
  def self.parse(url, config = nil)
    url = parse_url url
    parser = match_domain(url)

    return nil unless parser
    parser.new.perform(url, config)
  end
end
