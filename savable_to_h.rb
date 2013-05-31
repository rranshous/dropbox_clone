require 'savable'
class Savable::Savable
  def to_h
    result = {}
    result[:name] = name rescue nil
    result[:size] = data.bytesize rescue nil
    result[:path] = file_path rescue nil
    result[:version] = current_version rescue nil
    result
  end
end
