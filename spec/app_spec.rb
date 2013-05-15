require_relative '../app.rb'
require 'json'

describe DropboxClone do

  let(:savable_cls) { Class.new Savable::Savable }
  let(:dropbox) do
    c = Class.new(DropboxClone)
    i = c.new
    def i.savable
      Class.new(Savable::Savable).new
    end
    i
  end

  describe "#files" do

    it "has #files method" do
      expect(dropbox).to respond_to :files
    end

    it "returns ~hash as response" do
      expect(dropbox.files.kind_of?(Hash)).to eq true
    end

    it "response includes a headers key" do
      expect(dropbox.files.include?(:headers)).to eq true
    end

    it "response includes a body key" do
      expect(dropbox.files.include?(:body)).to eq true
    end

    it "found response headers include metadata header key" do
      def dropbox.load_file *args
        savable # pretend it was found
      end
      headers = dropbox.files('found')[:headers]
      expect(headers.include?('x-dropbox-metadata')).to eq true
    end

    it "found response metadata header is json encoded data" do
      def dropbox.load_file *args
        savable # pretend it was found
      end
      metadata = dropbox.files('found')[:headers]['x-dropbox-metadata']
      expect{ JSON.parse metadata }.not_to raise_error
    end

    it "found response metadata header is json encoded hash" do
      def dropbox.load_file *args
        savable # pretend it was found
      end
      metadata = dropbox.files('found')[:headers]['x-dropbox-metadata']
      expect(JSON.parse(metadata).kind_of?(Hash)).to eq true
    end

    it "response includes response code" do
      expect(dropbox.files.include?(:response_code)).to eq true
    end

    it "takes the file's path as an arg" do
      expect { dropbox.files('file_path.txt') }.not_to raise_error
    end

    it "responds with 404 if no path is given" do
      expect(dropbox.files[:response_code]).to eq 404
    end

    it "responds with 200 if file was found" do
      def dropbox.load_file *args
        savable # pretend it was found
      end
      expect(dropbox.files('found_file.txt')[:response_code]).to eq 200
    end

    it "responds with 404 if file was not found" do
      expect(dropbox.files('made_up_file.txt')[:response_code]).to eq 404
    end

    it "has blank body value if file was not found" do
      expect(dropbox.files('fake.txt')[:body]).to eq nil
    end

    it "has file data as body if file was found" do
      def dropbox.load_file *args
        s = savable # pretend it was found
        s.data = 'fakedata'
        s
      end
      expect(dropbox.files('found.txt')[:body]).to eq 'fakedata'
    end

    it "has file's metadata in metadata hash if found" do
      def dropbox.load_file *args
        s = savable
        s.data = 'fakedata'
        s['testkey'] = 'testsuccess'
        s
      end
      metadata = dropbox.files('found.txt')[:headers]['x-dropbox-metadata']
      metadata = JSON.parse metadata
      expect(metadata['testkey']).to eq 'testsuccess'
    end

    it "takes optional revision param" do
      expect{ dropbox.files('filepath', 'rev') }.not_to raise_error
    end

  end

end
