require_relative '../savable_to_h.rb'

describe Savable::Savable do
  let(:savable) { Savable::Savable.new }
  let(:savable_versioned) { Savable::SavableVersioned.new }

  describe "#to_h" do

    it "takes no args" do
      expect { savable.to_h }.not_to raise_exception
    end

    it "returns a hash" do
      expect(savable.to_h).to be_a_kind_of Hash
    end

    it "tries to return name" do
      expect(savable.to_h).to include :name
    end

    it "returns name off savable if present" do
      def savable.name
        :savable_name
      end
      expect(savable.to_h[:name]).to eq :savable_name
    end

    it "tries to return the file size" do
      expect(savable.to_h).to include :size
    end

    it "returns savable's data's size" do
      def savable.data
        'mydata'
      end
      expect(savable.to_h[:size]).to eq 'mydata'.bytesize
    end

    it "tries to return the file's path" do
      expect(savable.to_h).to include :path
    end

    it "returns the file's path" do
      def savable.file_path
        '/my/file.txt'
      end
      expect(savable.to_h[:path]).to eq '/my/file.txt'
    end

    it "tries to return the file's revision" do
      expect(savable.to_h).to include :version
    end

    it "returns the revision" do
      def savable.current_version
        '123.321'
      end
      expect(savable.to_h[:version]).to eq '123.321'
    end
  end
end
