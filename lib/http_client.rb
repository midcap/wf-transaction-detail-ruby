require 'net/http'
require 'uri'

module TransactionDetail
  class Client
    API_BASE_URL = 'WF_API_BASE_URL'
    TRANSACTION_DETAIL_SCOPE = 'WF_TRANSACTION_DETAIL_SCOPE'
    ENTITY_ID = 'WF_GATEWAY_ENTITY_ID'
    APPLICATION_ID = 'WF_GATEWAY_APPLICATION_ID'
    TOKEN_PATH = 'WF_API_TOKEN_PATH'
    PUBLIC_CERT = 'WF_PUBLIC_CERT'
    PRIVATE_KEY = 'WF_PRIVATE_KEY'
    CONSUMER_KEY = 'WF_GATEWAY_CONSUMER_KEY'
    CONSUMER_SECRET = 'WF_GATEWAY_CONSUMER_SECRET'

    def initialize(creds)
      uri = ENV[API_BASE_URL]
      scope = ENV[TRANSACTION_DETAIL_SCOPE]
      entity_id = ENV[ENTITY_ID]
      application_id = ENV[APPLICATION_ID]
      consumer_key = ENV[CONSUMER_KEY]
      consumer_secret = ENV[CONSUMER_SECRET]
      cert = ENV[PUBLIC_CERT]
      key = ENV[PRIVATE_KEY]
      validate_required_args({
        'uri' => uri,
        'scope' => scope,
        'creds' => creds,
        'entity_id' => entity_id,
        'application_id' => application_id,
      })
      @scope = scope
      @base_uri = URI(uri)
      @creds = creds
      @application_id = application_id
      @entity_id = entity_id
      @authenticated = false
    end

    def refresh_token(creds)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 15 #seconds
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      token_uri = @base_uri
      token_uri.path = ENV[TOKEN_PATH].blank? ? '/token' : ENV[TOKEN_PATH]
      token_uri.query = URI.encode_www_form({
        grant_type: 'client_credentials',
        scope: URI.escape(@scope),
      })

      request = Net::HTTP::Post.new(token_uri)
      request.basic_auth(@creds[:username], @creds[:password])
      request['Content-Type'] = 'application/x-www-form-urlencoded'

      response = http.request(request)
      raise HTTPError, response unless response.is_a? Net::HTTPOK
      @authenticated = true
      @token = JSON.parse(response.read_body)['access_token']
    end

    def add_required_headers(request)
      unless @authenticated
        refresh_token(@creds)
      end
      request["Authorization"] = "Bearer #{@token}"
      request["client-request-id"] = @application_id
      request["gateway-entity-id"] = @entity_id
      request
    end

    def transaction_search(account_collection, start_datetime, end_datetime)
      raise TypeError, 'transaction_search expects an AccountCollection' unless account_collection.kind_of?(TransactionDetail::AccountCollection)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 15 #seconds
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.cert = OpenSSL::X509::Certificate.new(cert)
      http.key = OpenSSL::PKey::RSA.new(key)

      transaction_search_uri = @base_uri
      transaction_search_path = '/treasury/transaction-reporting/v3/transactions/search'
      transaction_search_uri.path = ENV[TRANSACTION_SEARCH_PATH].blank? ? transaction_search_path : ENV[TRANSACTION_SEARCH_PATH]

      payload = { "datetime_range" => {"start_transaction_datetime" => start_datetime, "end_transaction_datetime" => end_datetime }}
      payload.merge!(account_collection.as_json)
      request = Net::HTTP::Post.new(transaction_search_uri)
      request = add_required_headers(request)
      request['Content-Type'] = 'application/json'
      request.body = payload.to_json
      response = http.request(request)
      raise HTTPError, response unless response.is_a? Net::HTTPOK
      JSON.parse(response.read_body, object_class: TransactionDetail::Collection, create_additions: true)
    end

    def validate_required_args(args)
      errors = []
      errors << "WF_TOKEN_API_URL not found in environment" if args['uri'].blank?
      errors << "WF_TRANSACTION_DETAIL_SCOPE not found in environment" if args['scope'].blank?
      errors << "WF_GATEWAY_ENTITY_ID not found in environment" if args['entity_id'].blank?
      errors << "WF_GATEWAY_APPLICATION_ID not found in environment" if args['application_id'].blank?
      errors << "WF_GATEWAY_CONSUMER_KEY not found in environment" if args['consumer_key'].blank?
      errors << "WF_GATEWAY_CONSUMER_SECRET not found in environment" if args['consumer_secret'].blank?
      raise ArgumentError, errors.map{|e| "#{e}"}.join(', ').delete_suffix!(',') if errors.length > 0
    end

  end
end

