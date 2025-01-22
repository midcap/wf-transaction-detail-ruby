require 'net/http'
require 'securerandom'
require 'uri'
require 'logger'
require 'active_support/core_ext/object/blank.rb'

module WFTransactionDetail
  class Client
    API_BASE_URL = 'WF_API_BASE_URL'
    TRANSACTION_DETAIL_SCOPE = 'WF_TRANSACTION_DETAIL_SCOPE'
    ENTITY_ID = 'WF_GATEWAY_ENTITY_ID'
    TOKEN_PATH = 'WF_API_TOKEN_PATH'
    TRANSACTION_SEARCH_PATH = 'WF_TRANSACTION_SEARCH_PATH'
    TRANSACTION_SEARCH_LIMIT = 'WF_TRANSACTION_SEARCH_LIMIT'
    PUBLIC_CERT = 'WF_PUBLIC_CERT'
    PRIVATE_KEY = 'WF_PRIVATE_KEY'
    CONSUMER_KEY = 'WF_GATEWAY_CONSUMER_KEY'
    CONSUMER_SECRET = 'WF_GATEWAY_CONSUMER_SECRET'
    MAX_RETRIES = 'WF_MAX_RETRIES'
    DATETIME_FORMAT = '%Y-%m-%dT%H:%M:%SZ'
    DATE_FORMAT = '%Y-%m-%d'

    def initialize()
      uri = ENV[API_BASE_URL]
      scope = ENV[TRANSACTION_DETAIL_SCOPE]
      entity_id = ENV[ENTITY_ID]
      consumer_key = ENV[CONSUMER_KEY]
      consumer_secret = ENV[CONSUMER_SECRET]
      cert = ENV[PUBLIC_CERT]
      key = ENV[PRIVATE_KEY]
      validate_required_args({
        'uri' => uri,
        'scope' => scope,
        'entity_id' => entity_id,
        'consumer_key' => consumer_key,
        'consumer_secret' => consumer_secret,
        'cert' => cert,
        'key' => key
      })
      @logger = Logger.new(STDOUT)
      @max_retries = ENV[MAX_RETRIES].blank? ? 5 : ENV[MAX_RETRIES]
      @scope = scope
      @base_uri = URI(uri)
      @creds = {:username => consumer_key, :password => consumer_secret}
      @entity_id = entity_id
      @authenticated = false
      @cert = cert
      @key = key
    end

    def refresh_token()
      token_uri = @base_uri
      token_uri.path = ENV[TOKEN_PATH].blank? ? '/oauth2/v1/token' : ENV[TOKEN_PATH]
      token_uri.query = URI.encode_www_form({
        grant_type: 'client_credentials',
        scope: CGI.escape(@scope),
      })
      http = Net::HTTP.new(token_uri.host, token_uri.port)
      http.use_ssl = true
      http.read_timeout = 15 #seconds
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.cert = OpenSSL::X509::Certificate.new(@cert)
      http.key = OpenSSL::PKey::RSA.new(@key)
      request = Net::HTTP::Post.new(token_uri)
      request.basic_auth(@creds[:username], @creds[:password])
      request['Content-Type'] = 'application/x-www-form-urlencoded'

      response = http.request(request)
      raise HTTPError.new(response) unless response.is_a? Net::HTTPOK
      @authenticated = true
      @token = JSON.parse(response.read_body)['access_token']
    end

    def add_required_headers(request)
      unless @authenticated
        retries = 0
        begin
          refresh_token()
        rescue HTTPError => e
          if retries < @max_retries
            retries += 1
            max_sleep_seconds = Float(2 ** retries)
            sleep rand(0..max_sleep_seconds)
            retry
          else
            raise e
          end
        end
      end
      request["Authorization"] = "Bearer #{@token}"
      request["client-request-id"] = generate_uuid
      request["gateway-entity-id"] = @entity_id
      request
    end

    def generate_uuid
      SecureRandom.uuid
    end

    # account_collection:     (required) WFTransactionDetail::AccountCollection
    # debit_credit_indicator: available values are 'ALL', 'DEBIT', or 'CREDIT'
    # transaction_mode:       (required) available values are 'intraday' or 'previous_day_composite'
    # transaction_type:       specified when we want to narrow the search to a particular type.
    #                         a list of transaction_types can be found here: https://developer.wellsfargo.com/documentation/api-references/account-transactions/v3/transaction-detail-api-ref-v3#transaction-types-and-bai-codes
    #                         note: The start_datetime and end_datetime must be the current date if transaction_type is ACH, RTP or WIRE and transaction_field_name and transaction_field_value is provided in the request.
    #                               (This method does not support transaction_field_name and transaction_field_value yet.)
    # start_datetime:         (required) DateTime value
    # end_datetime:           (required) DateTime value
    # Wells Fargo docs for transactions/search - https://developer.wellsfargo.com/documentation/api-references/account-transactions/v3/transaction-detail-api-ref-v3#search-for-transactions
    def transaction_search(account_collection:, debit_credit_indicator:"ALL", transaction_mode: nil, start_datetime: nil, end_datetime: nil, next_cursor: nil, transaction_types: [])
      raise ArgumentError, 'transaction_mode required. accepted values are intraday or previous_day_composite' if !transaction_mode || !['intraday', 'previous_day_composite'].include?(transaction_mode)
      raise ArgumentError, 'start_datetime needs to be a DateTime value' if !start_datetime || !start_datetime.is_a?(DateTime)
      raise ArgumentError, 'end_datetime needs to be a DateTime value' if !end_datetime || !end_datetime.is_a?(DateTime)
      raise TypeError, 'transaction_search expects an AccountCollection' unless account_collection.kind_of?(WFTransactionDetail::AccountCollection)
      raise ArgumentError, "next_cursor is not valid" if next_cursor.present? && (!next_cursor.is_a?(String) || next_cursor.length < 37 || next_cursor.length > 43)
      transaction_search_uri = @base_uri
      transaction_search_path = '/treasury/transaction-reporting/v3/transactions/search'
      transaction_search_uri.path = ENV[TRANSACTION_SEARCH_PATH].blank? ? transaction_search_path : ENV[TRANSACTION_SEARCH_PATH]
      transaction_limit = ENV[TRANSACTION_SEARCH_LIMIT].blank? ? 100 : ENV[TRANSACTION_SEARCH_LIMIT]
      http = Net::HTTP.new(transaction_search_uri.host, transaction_search_uri.port)
      http.use_ssl = true
      http.read_timeout = 15 #seconds
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.cert = OpenSSL::X509::Certificate.new(@cert)
      http.key = OpenSSL::PKey::RSA.new(@key)
      payload = {
        "debit_credit_indicator" => debit_credit_indicator,
        "limit" => transaction_limit,
      }
      start_value = nil
      end_value = nil
      if transaction_mode == 'intraday'
        start_value = start_datetime.strftime(DATETIME_FORMAT)
        end_value = end_datetime.strftime(DATETIME_FORMAT)
        payload['datetime_range'] = {
          "start_transaction_datetime" => start_value,
          "end_transaction_datetime" => end_value
        }
      elsif transaction_mode == 'previous_day_composite'
        start_value = start_datetime.strftime(DATE_FORMAT)
        end_value = end_datetime.strftime(DATE_FORMAT)
        payload['date_range'] = {
          "start_posting_date" => start_value,
          "end_posting_date" => end_value
        }
      end
      if !transaction_types.empty?
        transaction_type_list = []
        transaction_types.each do |type|
          transaction_type_list << { "transaction_type" => type }
        end
        payload['transaction_type_list'] = transaction_type_list
      end
      payload.merge!(account_collection.as_json)
      payload.merge!({"next_cursor": next_cursor}) if next_cursor.present?
      request = Net::HTTP::Post.new(transaction_search_uri)
      request = add_required_headers(request)
      request['Content-Type'] = 'application/json'
      request.body = payload.to_json

      response = http.request(request)
      raise HTTPError.new(response) unless response.is_a? Net::HTTPOK
      collection = JSON.parse(response.read_body, object_class: WFTransactionDetail::Collection, create_additions: true)
      collection.add_client_request_id(request['client-request-id'])
      collection.add_client_request_datetime([
        start_value,
        end_value
      ])
      collection
    rescue HTTPError => e
      @logger.debug "(#{request['client-request-id']}) requesting transactions from Wells Fargo: #{payload}"
      raise e
    end

    def validate_required_args(args)
      errors = []
      errors << "WF_TOKEN_API_URL not found in environment" if args['uri'].blank?
      errors << "WF_TRANSACTION_DETAIL_SCOPE not found in environment" if args['scope'].blank?
      errors << "WF_GATEWAY_ENTITY_ID not found in environment" if args['entity_id'].blank?
      errors << "WF_GATEWAY_CONSUMER_KEY not found in environment" if args['consumer_key'].blank?
      errors << "WF_GATEWAY_CONSUMER_SECRET not found in environment" if args['consumer_secret'].blank?
      errors << "WF_PUBLIC_CERT not found in environment" if args['cert'].blank?
      errors << "WF_PRIVATE_KEY not found in environment" if args['key'].blank?
      raise ArgumentError, errors.map{|e| "#{e}"}.join(', ').chomp(',') if errors.length > 0
    end

  end
end

