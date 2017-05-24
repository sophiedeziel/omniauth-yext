require 'spec_helper'

describe OmniAuth::Strategies::Yext do
  subject { described_class.new(nil) }

  it 'adds a camelization for itself' do
    expect(OmniAuth::Utils.camelize('yext')).to eq('Yext')
  end

  describe '#client' do
    it 'has correct Yammer site' do
      expect(subject.client.site).to eq('https://www.yext.com')
    end

    it 'has correct authorize url' do
      expect(subject.client.options[:authorize_url]).to eq('https://www.yext.com/oauth2/authorize')
    end

    it 'has correct token url' do
      expect(subject.client.options[:token_url]).to eq('https://www.yext.com/oauth2/accesstoken')
    end
  end

  describe '#callback_path' do
    it 'has the correct callback path' do
      expect(subject.callback_path).to eq('/auth/yext/callback')
    end
  end

  describe '#uid' do
    before :each do
      allow(subject).to receive(:raw_info) { { 'id' => 'uid' } }
    end

    it 'returns the id from raw_info' do
      expect(subject.uid).to eq('uid')
    end
  end

  describe '#info' do
    context 'and therefore has all the necessary fields' do
      before :each do
        allow(subject).to receive(:raw_info) {
          {
            'full_name' => 'John Doe',
            'contact' => {
              'email_addresses' => [
                { 'type' => 'primary', 'address' => 'john.doe@example.com' }
              ]
            },
            'name' => 'JohnDoe'
          }
        }
      end

      it { expect(subject.info).to have_key :name }
      it { expect(subject.info).to have_key :email }
    end

    context 'and does not fail with empty response' do
      before :each do
        allow(subject).to receive(:raw_info) { {} }
      end

      it { expect { subject.info }.not_to raise_error }
    end
  end

  describe '#extra' do
    before :each do
      allow(subject).to receive(:raw_info) { { 'foo' => 'bar' } }
    end

    it { expect(subject.extra[:raw_info]).to eq('foo' => 'bar') }
  end

  describe '#raw_info' do
    before :each do
      response = double('response', parsed: { 'foo' => 'bar' })
      allow(subject).to receive(:access_token) { double('access token', get: response) }
    end

    it 'returns parsed response from access token' do
      expect(subject.raw_info).to eq('foo' => 'bar')
    end
  end
end
