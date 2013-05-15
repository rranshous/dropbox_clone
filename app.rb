require 'savable'

class DropboxClone

  def files file_path=nil, revision=nil
    dropbox_metadata = {}
    response = { headers: { },
                 body: nil,
                 response_code: 200 }
    if file_path.nil? || file_path.empty?
      response[:response_code] = 404
      return response
    end
    file = load_file file_path, revision
    if file.nil?
      response[:response_code] = 404
      return response
    end
    response[:body] = file.data
    dropbox_metadata.merge! file.meta_data
    response[:headers]['x-dropbox-metadata'] = JSON.generate dropbox_metadata
    return response
  end

  private

  def load_file file_path, revision=nil
    file = Savable::SavableVersioned.new
    file.file_name = file_path
    file.current_version = revision unless revision.nil?
    load_savable file
  end

  def load_savable savable
    savable.load
  rescue
    nil
  end
end
