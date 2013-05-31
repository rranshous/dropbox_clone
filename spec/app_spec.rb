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

  describe "#load_file" do

    it "takes a file path arg" do 
      def dropbox._load_file *args
        load_file *args
      end
      expect{ dropbox._load_file 'path' }.not_to raise_error
    end

    it "is private" do
      expect{ dropbox.load_file('path') }.to raise_error
    end

    it "takes an option revision arg" do
      def dropbox._load_file *args
        load_file *args
      end
      expect{ dropbox._load_file 'path', 'rev' }.not_to raise_error
    end

    it "returns nil if file not found" do
      def dropbox._load_file *args
        load_file *args
      end
      expect(dropbox._load_file('notfound')).to eq nil
    end

    it "returns savable if file is found" do
      def dropbox._load_file *args
        load_file *args
      end
      def dropbox.load_savable savable
        savable
      end
      expect(dropbox._load_file('path').kind_of?(Savable::Savable)).to eq true
    end

    it "sets file path as file name on returned savable" do
      def dropbox._load_file *args
        load_file *args
      end
      def dropbox.load_savable savable
        savable
      end
      expect(dropbox._load_file('path').file_name).to eq 'path'
    end

    it "sets revision as current version on returned savable" do
      def dropbox._load_file *args
        load_file *args
      end
      def dropbox.load_savable savable
        savable
      end
      expect(dropbox._load_file('path','1').current_version).to eq '1'
    end
  end

  describe "#load_savable" do
    it "calls load on passed savable" do
      def dropbox._load_savable *args
        load_savable *args
      end
      savable = savable_cls.new
      def savable.load
        @saved = true
      end
      def savable.saved
        @saved
      end
      dropbox._load_savable(savable)
      expect(savable.saved).to eq true
    end
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

  it "serializes the dropbox metadata" do
    def dropbox.dropbox_metadata *args
      { 'key' => 2 }
    end
    def dropbox._serialized_dropbox_metadata *args
      serialized_dropbox_metadata *args
    end
    hand_serialized = JSON.generate dropbox.dropbox_metadata
    expect(dropbox._serialized_dropbox_metadata :file).to eq hand_serialized
  end

  describe "#dropbox_metadata" do

    it "takes an argument" do
      expect{ dropbox.dropbox_metadata :savable }.not_to :raise_error
    end

    it "returns a hash" do
      expect(dropbox.dropbox_metadata :savable).to be_a_kind_of Hash
    end

  end

end
