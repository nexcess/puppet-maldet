require 'spec_helper'
require 'tmpdir'

describe Puppet::Type.type(:maldet).provider(:source) do
  let(:extract_dir) { Dir.mktmpdir }
  let(:resource) do
    Puppet::Type.type(:maldet).new(
      { :title => 'https://cdn.rfxn.com/downloads', :version => '1.6.6', :extract_dir => extract_dir }.merge(params)
    )
  end
  let(:provider) { described_class.new(resource) }

  after { FileUtils.rm_rf(extract_dir) }

  # Stands in for curl: writes the tarball bytes, and records the URL
  def fake_download(content)
    allow(provider).to receive(:curl) do |args|
      @url = args[args.index('-o') - 1]
      File.write(args[args.index('-o') + 1], content)
    end
  end

  # Stands in for tar: unpacks to dir/install.sh
  def fake_unpack(dir)
    allow(provider).to receive(:tar) do |_args|
      FileUtils.mkdir_p(File.join(extract_dir, dir))
      FileUtils.touch(File.join(extract_dir, dir, 'install.sh'))
    end
  end

  context 'without source' do
    let(:params) { {} }

    it 'downloads <mirror_url>/maldetect-<version>.tar.gz, as in 4.x' do
      fake_download('tarball')
      fake_unpack('maldetect-1.6.6')
      expect(provider.download_and_extract).to eq(File.join(extract_dir, 'maldetect-1.6.6'))
      expect(@url).to eq('https://cdn.rfxn.com/downloads/maldetect-1.6.6.tar.gz')
    end
  end

  context 'with source' do
    let(:source) { 'https://github.com/rfxn/linux-malware-detect/releases/download/v2.0.1/maldet-2.0.1.tar.gz' }
    let(:params) { { :version => '2.0.1', :source => source } }

    it 'downloads source and finds install.sh in the 2.x directory' do
      fake_download('tarball')
      fake_unpack('maldet-2.0.1')
      expect(provider.download_and_extract).to eq(File.join(extract_dir, 'maldet-2.0.1'))
      expect(@url).to eq(source)
    end
  end

  context 'with a checksum' do
    let(:params) { { :checksum => Digest::SHA256.hexdigest('tarball') } }

    it 'unpacks a matching download' do
      fake_download('tarball')
      fake_unpack('maldetect-1.6.6')
      expect(provider.download_and_extract).to eq(File.join(extract_dir, 'maldetect-1.6.6'))
    end

    it 'fails before unpacking a download that does not match' do
      fake_download('tampered')
      expect(provider).not_to receive(:tar)
      expect { provider.download_and_extract }.to raise_error(Puppet::Error, /checksum mismatch/)
      expect(File.exist?(extract_dir)).to be false
    end
  end
end
