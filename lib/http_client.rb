require 'net/http'
require 'securerandom'
require 'uri'
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
      token_uri.path = ENV[TOKEN_PATH].blank? ? '/token' : ENV[TOKEN_PATH]
      token_uri.query = URI.encode_www_form({
        grant_type: 'client_credentials',
        scope: URI.escape(@scope),
      })
      http = Net::HTTP.new(token_uri.host, token_uri.port)
      http.use_ssl = true
      http.read_timeout = 15 #seconds
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
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

    def transaction_search(account_collection, start_datetime, end_datetime, debit_credit_indicator="ALL")
      raise TypeError, 'transaction_search expects an AccountCollection' unless account_collection.kind_of?(WFTransactionDetail::AccountCollection)
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
        "datetime_range" => {
          "start_transaction_datetime" => start_datetime.strftime(DATETIME_FORMAT),
          "end_transaction_datetime" => end_datetime.strftime(DATETIME_FORMAT)
        },
        "debit_credit_indicator" => debit_credit_indicator,
        "limit" => transaction_limit,
      }
      payload.merge!(account_collection.as_json)
      request = Net::HTTP::Post.new(transaction_search_uri)
      request = add_required_headers(request)
      request['Content-Type'] = 'application/json'
      request.body = payload.to_json
      response = http.request(request)
      raise HTTPError.new(response) unless response.is_a? Net::HTTPOK
      collection = JSON.parse(response.read_body, object_class: WFTransactionDetail::Collection, create_additions: true)
      collection.add_client_request_id(request['client-request-id'])
      collection.add_client_request_datetime([
        start_datetime.strftime(DATETIME_FORMAT),
        end_datetime.strftime(DATETIME_FORMAT)
      ])
      collection
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

