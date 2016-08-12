class BaseCrawler
  cattr_accessor :domain_map, instance_accessor: false do
    {}
  end

  class_attribute :domain, :cookie_filename

  class << self
    def for_domain(domain, dispatch_to: false)
      self.domain = domain
      domain_map[domain] = self if dispatch_to
    end

    def save_cookie_to(filename)
      self.cookie_filename = filename
    end

    def match_domain(url)
      begin
        uri = parse_url url
        domain_map.each do |k, v|
          return v if uri.host.end_with?(k)
        end
      rescue
        return nil
      end
      nil
    end

    def parse_url(url)
      url = URI.encode url if url.instance_of? String
      url = URI.parse(url) unless url.instance_of? URI::HTTP
      url
    end
  end

  attr_reader :agent

  def initialize
    @agent = Mechanize.new
    @agent.user_agent_alias = 'Windows IE 9'
    @agent.follow_meta_refresh = true
  end

  def perform(url, config = nil)
    setup(url, config)
    start
  end

  def setup(url, config)
    @url = self.class.parse_url url
    @config = OpenStruct.new config
  end

  def start
  end

  def page
    agent.page
  end

  def domain
    self.class.domain
  end

  def credential_path
    Rails.configuration.x.credentials_path.join cookie_filename
  end

  def load_crdential
    if File.exist?(credential_path)
      Hashie::Mash.load(credential_path)
    else
      Hashie::Mash.new
    end
  end

  def credential
    @credential ||= load_credential
  end

  def cookie_filename
    self.class.cookie_filename || domain.parameterize
  end

  def save_cookies
    agent.cookie_jar.save cookie_path, session: true
  end

  def load_cookies(cookie_file = nil)
    agent.cookie_jar.load cookie_path(cookie_file) if File.exist?(cookie_path(cookie_file))
  end

  def cookie_path(cookie_file = nil)
    cookie_file ||= cookie_filename
    Rails.configuration.x.cookie_path.join(cookie_file).to_s
  end

  def temp_path
    Rails.root.join 'tmp'
  end

  def generate_random_filename(ext: nil)
    filename = SecureRandom.urlsafe_base64
    filename + '.' + (ext || file_extension)
  end

  def file_extension
    response_type = MIME::Types[page.response['content-type']].first
    response_type.extensions.first
  end

  def filename
    "#{File.basename(page.filename, '.*')}.#{file_extension}"
  end
end
