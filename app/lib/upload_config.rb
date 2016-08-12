class UploadConfig < OpenStruct
  def initialize(adapter = nil, config = nil)
    @adapter = adapter&.to_s
    super(config)
  end

  def adapter
    @adapter&.constantize&.new(self)
  end
end
