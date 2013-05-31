require 'savable'
require_relative 'savable_to_h'
require_relative 'humanize'

class DropboxClone

  def files file_path=nil, revision=nil
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
    response[:headers]['x-dropbox-metadata'] = serialized_dropbox_metadata file
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

  def serialized_dropbox_metadata file
    JSON.generate dropbox_metadata file
  end

  def dropbox_metadata file
    result = {}
    result.merge! file.meta_data
    f_h = file.to_h
    human_size = f_h[:size].humanize rescue nil
    result.merge! 'size'  => human_size,
                  'bytes' => f_h[:size],
                  'path'  => f_h[:path],
                  'rev'   => f_h[:version]
    result
  end
end
