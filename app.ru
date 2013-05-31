$: << File.absolute_path('.')
require 'savable'
require 'savable_to_h'
require 'humanize'
require 'racker'

class DropboxClone

  include Racker

  def files *file_path
    puts "files: file path: #{file_path}"
    r = _files file_path.join('/'), @request.params[:revision]
    r[:body] = JSON.generate r[:body] unless r[:body].nil?
    return r
  end

  private

  def _files file_path=nil, revision=nil
    puts "_files file_path: #{file_path}"
    puts "_files revision: #{revision}"
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
    result.merge! file.meta_data rescue {}
    f_h = file.to_h rescue {}
    human_size = f_h[:size].humanize rescue nil
    result.merge! 'size'  => human_size,
                  'bytes' => f_h[:size],
                  'path'  => f_h[:path],
                  'rev'   => f_h[:version]
    result
  end
end

app = proc { |env|
  app = DropboxClone.new env
  begin
    response = app.run
    response[:body] = [] if response[:body].nil?
    response[:body] = [response[:body]] unless response[:body].kind_of? Array
    [response[:response_code], response[:headers], response[:body]]
  rescue => ex
    puts "EXCEPTION: #{ex} #{ex.backtrace.join("\n")}"
    [500, {'Content-Type'=>'text-html'}, ex.to_s]
  end
}
run app
