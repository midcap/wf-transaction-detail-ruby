require 'http_client'
require 'account_collection'
require 'transaction_collection'
require 'spec_helper'
require 'http_error'

describe WFTransactionDetail::Client do
  DATETIME_FORMAT = '%Y-%m-%dT%H:%M:%SZ'
  it 'will validate environment variables' do
    expect { WFTransactionDetail::Client.new() }.to raise_error(ArgumentError)
  end

  describe 'correctly set environment' do
    before :each do
      # TODO: should ENV be stubbed? revisit
      allow(ENV).to receive(:[]).with("WF_API_BASE_URL").and_return("https://api-sandbox.wellsfargo.com")
      allow(ENV).to receive(:[]).with("WF_TRANSACTION_DETAIL_SCOPE").and_return("TM-Transaction-Search")
      allow(ENV).to receive(:[]).with("WF_GATEWAY_ENTITY_ID").and_return("bogus-entity-id")
      allow(ENV).to receive(:[]).with("WF_PUBLIC_CERT").and_return("-----BEGIN CERTIFICATE-----\n-----END CERTIFICATE-----")
      allow(ENV).to receive(:[]).with("WF_PRIVATE_KEY").and_return("-----BEGIN PRIVATE KEY-----\n-----END PRIVATE KEY-----")
      allow(ENV).to receive(:[]).with("WF_GATEWAY_CONSUMER_KEY").and_return("boguskey")
      allow(ENV).to receive(:[]).with("WF_GATEWAY_CONSUMER_SECRET").and_return("bogussecret")
      allow(ENV).to receive(:[]).with("WF_API_TOKEN_PATH").and_return(nil)
      allow(ENV).to receive(:[]).with("WF_TRANSACTION_SEARCH_PATH").and_return(nil)
      allow(ENV).to receive(:[]).with("WF_TRANSACTION_SEARCH_LIMIT").and_return(nil)
      allow(ENV).to receive(:[]).with("WF_MAX_RETRIES").and_return(nil)
      allow(OpenSSL::X509::Certificate).to receive(:new).with("-----BEGIN CERTIFICATE-----\n-----END CERTIFICATE-----").and_return(true)
      allow(OpenSSL::PKey::RSA).to receive(:new).with("-----BEGIN PRIVATE KEY-----\n-----END PRIVATE KEY-----").and_return(true)
      allow_any_instance_of(WFTransactionDetail::Client).to receive(:generate_uuid).and_return("bogus-request-id")
    end

    let(:client) { WFTransactionDetail::Client.new() }

    it 'can retrieve an api token' do
      token = client.refresh_token
      expect(token).to eq('bogustogus')  # see spec_helper for registered webmock request stubs and responses
    end

    it 'can retrieve transactions' do
      accounts = WFTransactionDetail::AccountCollection.new("111111111", ["2222222222","3333333333"])
      start_datetime = DateTime.new(2019,9,11,0,0,0)
      end_datetime = DateTime.new(2019,9,11,23,59,59)
      datetime_range = {
        'start_datetime' => start_datetime,
        'end_datetime' => end_datetime
      }
      transaction_detail = client.transaction_search(
        account_collection: accounts,
        datetime_range: datetime_range
      )

      expect(transaction_detail.transactions(2222222222).length).to eq(3)
      expect(transaction_detail.transactions(2222222222)[0].transaction_amount).to eq(253.75)
      expect(transaction_detail.transactions(2222222222)[1].transaction_amount).to eq(163649.84)

      expect(transaction_detail.transactions(3333333333).length).to eq(3)
      expect(transaction_detail.transactions(3333333333)[0].transaction_amount).to eq(252.53)
      expect(transaction_detail.transactions(3333333333)[1].transaction_amount).to eq(39882.09)
      expect(transaction_detail.client_request_id).to eq('bogus-request-id')
      expect(transaction_detail.client_request_start_datetime).to eq(start_datetime.strftime(DATETIME_FORMAT))
      expect(transaction_detail.client_request_end_datetime).to eq(end_datetime.strftime(DATETIME_FORMAT))

      # Should only return transactions within the given range
      expect(DateTime.strptime(transaction_detail.transactions(2222222222)[0].transaction_datetime, '%Y-%m-%d %H:%M:%SZ')).to be_between(start_datetime, end_datetime)
      expect(DateTime.strptime(transaction_detail.transactions(3333333333)[0].transaction_datetime, '%Y-%m-%d %H:%M:%SZ')).to be_between(start_datetime, end_datetime)
    end

    it 'returns a http error obj for non-success' do
      allow(ENV).to receive(:[]).with("WF_GATEWAY_CONSUMER_KEY").and_return("invalid")
      allow(ENV).to receive(:[]).with("WF_GATEWAY_CONSUMER_SECRET").and_return("invalid")
      allow(ENV).to receive(:[]).with("WF_MAX_RETRIES").and_return(0)
      accounts = WFTransactionDetail::AccountCollection.new("111111111", ["2222222222","3333333333"])
      start_datetime = DateTime.new(2019,9,11,0,0,0)
      end_datetime = DateTime.new(2019,9,11,23,59,59)
      datetime_range = {
        'start_datetime' => start_datetime,
        'end_datetime' => end_datetime
      }
      expect{ client.transaction_search(
        account_collection: accounts,
        datetime_range: datetime_range
      ) }.to raise_error(WFTransactionDetail::HTTPError, "Unauthorized")
    end

    it 'returns a http error with a message and a body' do
      accounts = WFTransactionDetail::AccountCollection.new("111111111", ["2222222222","3333333333"])
      start_datetime = DateTime.new(2019,9,11,0,0,0)
      end_datetime = DateTime.new(2019,9,18,23,59,59)
      datetime_range = {
        'start_datetime' => start_datetime,
        'end_datetime' => end_datetime
      }
      expect{ client.transaction_search(
        account_collection: accounts,
        datetime_range: datetime_range
      ) }.to raise_error(WFTransactionDetail::HTTPError, /\{"errors":\[\{"error_code":"1018-011","description"/)
    end

    it 'returns an argument error for invalid next_cursor' do
      accounts = WFTransactionDetail::AccountCollection.new("111111111", ["2222222222","3333333333"])
      start_datetime = DateTime.new(2019,9,11,0,0,0)
      end_datetime = DateTime.new(2019,9,11,23,59,59)
      datetime_range = {
        'start_datetime' => start_datetime,
        'end_datetime' => end_datetime
      }
      expect{ client.transaction_search(
        account_collection: accounts,
        datetime_range: datetime_range,
        next_cursor:"123415t"
      ) }.to raise_error(ArgumentError)
    end

    it 'returns nil for next_cursor when not present' do
      accounts = WFTransactionDetail::AccountCollection.new("111111111", ["2222222222","3333333333"])
      start_datetime = DateTime.new(2019,9,11,0,0,0)
      end_datetime = DateTime.new(2019,9,11,23,59,59)
      datetime_range = {
        'start_datetime' => start_datetime,
        'end_datetime' => end_datetime
      }
      collection = client.transaction_search(
        account_collection: accounts,
        datetime_range: datetime_range
      )
      expect(collection.next_cursor).to be(nil)
    end

    it 'returns nil for next_cursor when no transactions' do
      accounts = WFTransactionDetail::AccountCollection.new("111111111", ["2222222222","3333333333"])
      start_datetime = DateTime.new(2019,9,11,0,0,0)
      end_datetime = DateTime.new(2019,9,11,0,0,01)
      datetime_range = {
        'start_datetime' => start_datetime,
        'end_datetime' => end_datetime
      }
      collection = client.transaction_search(
        account_collection: accounts,
        datetime_range: datetime_range
      )
      expect(collection.next_cursor).to be(nil)
    end

    it 'sets transaction_type_list in the payload if transaction_types are provided' do
      accounts = WFTransactionDetail::AccountCollection.new("111111111", ["2222222222","3333333333"])
      date = Date.new(2019,9,11)
      date_range = {
        'start_date' => date,
        'end_date' => date
      }
      collection = client.transaction_search(
        account_collection: accounts,
        date_range: date_range,
        transaction_types: ['MISCELLANEOUS', 'ACH']
      )
      expect(collection.transactions(2222222222).length).to eq(3)
    end

    it 'returns an argument error if datetime_range and date_range are not provided' do
      accounts = WFTransactionDetail::AccountCollection.new("111111111", ["2222222222","3333333333"])
      expect{ client.transaction_search(
        account_collection: accounts
      ) }.to raise_error(ArgumentError)
    end

    it 'returns an argument error if both datetime_range and date_range are provided' do
      accounts = WFTransactionDetail::AccountCollection.new("111111111", ["2222222222","3333333333"])
      date_range = {
        'start_date' => Date.new(2019,9,11),
        'end_date' => Date.new(2019,9,11)
      }
      datetime_range = {
        'start_datetime' => DateTime.new(2019,9,11,0,0,0),
        'end_datetime' => DateTime.new(2019,9,11,0,0,0)
      }
      expect{ client.transaction_search(
        account_collection: accounts,
        date_range: date_range,
        datetime_range: datetime_range
      ) }.to raise_error(ArgumentError)
    end

    it 'returns an argument error if a date_range is provided but start_date is not provided' do
      accounts = WFTransactionDetail::AccountCollection.new("111111111", ["2222222222","3333333333"])
      date_range = {
        'end_date' => Date.new(2019,9,11)
      }
      expect{ client.transaction_search(
        account_collection: accounts,
        date_range: date_range
      ) }.to raise_error(ArgumentError)
    end

    it 'returns an argument error if a date_range is provided but end_date is not provided' do
      accounts = WFTransactionDetail::AccountCollection.new("111111111", ["2222222222","3333333333"])
      date_range = {
        'start_date' => Date.new(2019,9,11)
      }
      expect{ client.transaction_search(
        account_collection: accounts,
        date_range: date_range
      ) }.to raise_error(ArgumentError)
    end

    it 'returns an argument error if a datetime_range is provided but end_datetime is not provided' do
      accounts = WFTransactionDetail::AccountCollection.new("111111111", ["2222222222","3333333333"])
      date_range = {
        'start_datetime' => DateTime.new(2019,9,11,0,0,0)
      }
      expect{ client.transaction_search(
        account_collection: accounts,
        date_range: date_range
      ) }.to raise_error(ArgumentError)
    end

    it 'returns an argument error if a datetime_range is provided but start_datetime is not provided' do
      accounts = WFTransactionDetail::AccountCollection.new("111111111", ["2222222222","3333333333"])
      date_range = {
        'end_datetime' => DateTime.new(2019,9,11,0,0,0)
      }
      expect{ client.transaction_search(
        account_collection: accounts,
        date_range: date_range
      ) }.to raise_error(ArgumentError)
    end

  end
end

