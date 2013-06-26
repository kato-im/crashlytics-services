require 'spec_helper'

describe Service::Kato do
  it 'should have a title' do
    Service::Kato.title.should == 'Kato'
  end

  describe 'receive_verification' do
    before do
      @config = { :url => 'https://example.org' }
      @service = Service::Kato.new('verification', {})
      @payload = {}
    end

    it 'should respond' do
      @service.respond_to?(:receive_verification)
    end

    it 'should succeed upon successful api response' do
      test = Faraday.new do |builder|
        builder.adapter :test do |stub|
          stub.post('/') { [200, {}, ''] }
        end
      end

      @service.should_receive(:http_post)
        .with('https://example.org')
        .and_return(test.post('/'))

      resp = @service.receive_verification(@config, @payload)
      resp.should == [true,  'Success. Verification message should be already in chat room.']
    end

    it 'should fail upon unsuccessful api response' do
      test = Faraday.new do |builder|
        builder.adapter :test do |stub|
          stub.post('/') { [500, {}, ''] }
        end
      end

      @service.should_receive(:http_post)
        .with('https://example.org')
        .and_return(test.post('/'))

      resp = @service.receive_verification(@config, @payload)
      resp.should == [false, "Oops! Is webhook url correct?"]
    end
  end

  describe 'receive_issue_impact_change' do
    before do
      @config = { :url => 'https://example.org' }
      @service = Service::Kato.new('issue_impact_change', {})
      @payload = {
        :title => 'foo title',
        :impact_level => 1,
        :impacted_devices_count => 1,
        :crashes_count => 1,
        :app => {
          :name => 'foo name',
          :bundle_identifier => 'foo.bar.baz'
        }
      }
    end

    it 'should respond to receive_issue_impact_change' do
      @service.respond_to?(:receive_issue_impact_change)
    end

    it 'should succeed upon successful api response' do
      test = Faraday.new do |builder|
        builder.adapter :test do |stub|
          stub.post('/') { [200, {}, ''] }
        end
      end

      @service.should_receive(:http_post)
        .with('https://example.org')
        .and_return(test.post('/'))

      resp = @service.receive_issue_impact_change(@config, @payload)
      resp.should == :no_resource
    end

    it 'should fail upon unsuccessful api response' do
      test = Faraday.new do |builder|
        builder.adapter :test do |stub|
          stub.post('/') { [500, {}, ''] }
        end
      end

      @service.should_receive(:http_post)
        .with('https://example.org')
        .and_return(test.post('/'))

      lambda { @service.receive_issue_impact_change(@config, @payload) }.should raise_error
    end
  end
end
