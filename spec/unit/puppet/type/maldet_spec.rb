require 'spec_helper'

describe Puppet::Type.type(:maldet) do
  it 'is titled by mirror_url, as in 4.x' do
    expect(described_class.key_attributes).to eq([:mirror_url])
    resource = described_class.new(:title => 'https://cdn.rfxn.com/downloads')
    expect(resource[:mirror_url]).to eq('https://cdn.rfxn.com/downloads')
  end

  it 'leaves source and checksum unset by default' do
    resource = described_class.new(:title => 'https://cdn.rfxn.com/downloads')
    expect(resource[:source]).to be_nil
    expect(resource[:checksum]).to be_nil
  end

  it 'accepts a lowercase hex SHA-256 checksum' do
    sum = '26674c72208a4c32ae4ed8770a2b5c036b35c0894a4812450df11c5a53d7d8e5'
    resource = described_class.new(:title => 'x', :checksum => sum)
    expect(resource[:checksum]).to eq(sum)
  end

  ['26674C72208A4C32AE4ED8770A2B5C036B35C0894A4812450DF11C5A53D7D8E5', 'abc123'].each do |bad|
    it "rejects checksum #{bad}" do
      expect {
        described_class.new(:title => 'x', :checksum => bad)
      }.to raise_error(Puppet::ResourceError, /lowercase hex SHA-256/)
    end
  end
end
