require 'google/apis/drive_v3'

# Wrapper for Google Drive
class GoogleDrive
  Drive = Google::Apis::DriveV3
  Google::Apis::RequestOptions.default.authorization = GoogleAuthentication.new.get_credential
  attr_reader :drive

  def initialize
    @drive = Drive::DriveService.new
  end

  def sanitize_name(name)
    name.tr("'", '_').gsub(%r{/}, '_')
  end

  def find_or_create_parent(remote_path = '/', create = true, from: 'root')
    current_parent_id = from
    dics = remote_path.split('/')
    dics.each do |dic|
      next unless dic

      dicionary = drive.list_files(q: "name = '#{dic}'" \
        " and mimeType = 'application/vnd.google-apps.folder'" \
        " and '#{current_parent_id}' in parents" \
        ' and trashed = false')

      if dicionary.files.empty?
        if create
          current_parent_id = create_folder(dic, current_parent_id).id
        else
          return nil
        end
      else
        current_parent_id = dicionary.files.first.id
      end
    end
    current_parent_id
  end

  def create_folder(name, parent = 'root')
    folder = Drive::File.new(
      name: name,
      mime_type: 'application/vnd.google-apps.folder',
      parents: [parent])
    drive.create_file(folder)
  end

  def upload_to_parent(local_file, parent_id)
    filename = File.basename local_file
    metadata = Drive::File.new(name: filename,
                               parents: [parent_id])
    drive.create_file(metadata, upload_source: local_file)
  end

  def upload_to(local_file, remote_path)
    upload_to_parent(local_file, find_or_create_parent(remote_path))
  end

  def delete_file(id)
    drive.delete_file(id)
  end

  def exists?(file_path, parent_id: 'root')
    parent = find_or_create_parent(File.path(file_path), false, from: parent_id)
    if parent
      files = drive.list_files(q: "name='#{File.basename(file_path)}'"\
        " and '#{parent}'"\
        ' in parents and trashed = false')
      return files.files.first unless files.files.empty?
    end
    false
  end
end
