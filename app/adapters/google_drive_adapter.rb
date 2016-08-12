class GoogleDriveAdapter < BaseAdapter
  def start_upload
    drive = GoogleDrive.new

    remove_exsiting_file if @config.overwrite

    drive.upload_to_parent(@local_file, @config.parent_id) if @config.parent_id
    drive.upload_to(@local_file, @config.remote_path) if @config.remote_path
  end

  def remove_exsiting_file
    filename = File.basename @local_file
    if @config.remote_path
      @config.parent_id = drive.find_or_create_parent(@config.remote_path)
    end
    file = drive.exists?(filename, parent_id: @config.parent_id)
    drive.delete_file(file.id) if file
  end
end
