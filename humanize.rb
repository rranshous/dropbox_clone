# ty: http://constellation.hatenablog.com/entry/20090424/1240570837
class Fixnum
  def humanize
    bytes = %w(B K M G T P E Z Y)
    size = self
    cnt = 0
    loop do
      break if size <= 1023 && cnt < 8
      size /= 1024.0
      cnt += 1
    end
    if 0 < size && size <= 9
      return "#{(size*10.0).ceil.round(1)}#{bytes[cnt]}"
    else
      return "#{size.ceil}#{bytes[cnt]}"
    end
  end
end
