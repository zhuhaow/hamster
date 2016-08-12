require 'rails_helper'

RSpec.describe GoogleDrive do
  before(:each) do
    @drive = GoogleDrive.new
  end

  it 'can sanitize remote to a valid one' do
    {
      "path'path" => 'path_path',
      "path'path'path" => 'path_path_path',
      'path/path' => 'path_path'
    }.each do |k, v|
      expect(@drive.sanitize_name k).to eq v
    end
  end

  it 'can create folders by given path' do
    filename = SecureRandom.urlsafe_base64
    expect(@drive.find_or_create_parent "test/#{filename}").to \
      eq @drive.find_or_create_parent("test/#{filename}")
  end

  it 'can upload file to Google Drive' do
    filename = Rails.root.join('spec/assets/hamster.jpg').to_s
    file = @drive.upload_to(filename, 'test')
    expect(file).to_not be_nil
    @drive.delete_file file.id
  end
end
