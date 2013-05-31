require 'rack/request'

module Racker

  def initialize env
    @request = Rack::Request.new env
  end

  def run
    run_path_pieces
  end

  private

  def run_path_pieces
    object = nil
    args = []
    response = {}
    @request.path.split('/').chunk do |path_piece|
      object = path_piece if respond_to?(path_piece)
      object
    end.each do |object, args|
      puts "RUNNING: #{object} #{args[1..-1]}"
      call_result = send(object, *args[1..-1])
      puts "CALL RESULT: #{call_result}"
      response.merge! call_result
      puts "RESULT: #{response}"
    end
    return response
  end

  def request_path
    @environ['REQUEST_PATH']
  end
end
