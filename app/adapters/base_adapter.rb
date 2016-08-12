class BaseAdapter
  def initialize(config)
    @config = config
  end

  def upload(path)
    @local_file = path

    File.delete(@local_file) if start_upload && @config.delete_temp
  end

  def start_upload
  end
end
