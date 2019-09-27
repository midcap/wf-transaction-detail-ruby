require 'webmock/rspec'
require "bundler/setup"
# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# The generated `.rspec` file contains `--require spec_helper` which will cause
# this file to always be loaded, without a need to explicitly require it in any
# files.
#
# Given that it is always loaded, you are encouraged to keep this file as
# light-weight as possible. Requiring heavyweight dependencies from this file
# will add to the boot time of your test suite on EVERY test run, even for an
# individual file that may not need all of that loaded. Instead, consider making
# a separate helper file that requires the additional dependencies and performs
# the additional setup, and require it from the spec files that actually need
# it.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  # Webmock for HTTP client
  config.before(:each) do
    stub_request(:post, "https://api-sandbox.wellsfargo.com/token?grant_type=client_credentials&scope=TM-Transaction-Search").
        with(
            headers: {
                'Accept' => '*/*',
                'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                'Authorization' => 'Basic Ym9ndXNrZXk6Ym9ndXNzZWNyZXQ=',
                'Content-Type' => 'application/x-www-form-urlencoded',
                'Host' => 'api-sandbox.wellsfargo.com',
                'User-Agent' => 'Ruby'
            }).
        to_return(status: 200, body: "{\"access_token\":\"bogustogus\",\"scope\":\"TM-Transaction-Search am_application_scope\",\"token_type\":\"Bearer\",\"expires_in\":86400}", headers: {})
    stub_request(:post, "https://api-sandbox.wellsfargo.com/treasury/transaction-reporting/v3/transactions/search").
        with(
            body: "{\"datetime_range\":{\"start_transaction_datetime\":\"2019-09-11T00:00:00Z\",\"end_transaction_datetime\":\"2019-09-11T23:59:59Z\"},\"accounts\":[{\"bank_id\":\"111111111\",\"account_number\":\"2222222222\"},{\"bank_id\":\"111111111\",\"account_number\":\"3333333333\"}]}",
            headers: {
                'Accept' => '*/*',
                'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                'Authorization' => 'Bearer bogustogus',
                'Content-Type' => 'application/json',
                'Client-Request-Id' => 'bogus-request-id',
                'Gateway-Entity-Id' => 'bogus-entity-id',
                'Host' => 'api-sandbox.wellsfargo.com',
                'User-Agent' => 'Ruby'
            }).
        to_return(status: 200, body: "{\"accounts\":[{\"bank_id\":\"111111111\",\"account_number\":\"2222222222\",\"account_type\":\"DEMAND_DEPOSIT\",\"account_name\":\"MIDCAP BUSINESS CREDIT LLC\",\"currency_code\":\"USD\",\"transaction_count\":3,\"transactions\":[{\"posting_date\":\"2019-09-11\",\"value_date\":\"2019-09-11\",\"transaction_datetime\":\"2019-09-11 16:08:56Z\",\"debit_credit_indicator\":\"DEBIT\",\"transaction_type\":\"ACH\",\"bai_type_code\":\"455\",\"transaction_description\":\"COMPANY NAME:  CLIENT ANALYSIS                    SRVC CHRG ENTRY DESC:    SRVC CHRG RECIPIENT ID:   SVC CHGE 0819 RECIPIENT NAME:000004764506150 COMPANY ID:    DP10700543 ENTRY CLASS CODE:   PPD DISCRETIONARY DATA: TRANSACTION CODE: 27\",\"transaction_amount\":253.75,\"zero_day_float\":0.00,\"one_day_float\":0.00,\"two_date_float\":0.00,\"customer_reference_number\":\"091000018762757\",\"transaction_status\":\"RECEIVED\"},{\"posting_date\":\"2019-09-11\",\"value_date\":\"2019-09-11\",\"transaction_datetime\":\"2019-09-11 13:30:51Z\",\"debit_credit_indicator\":\"DEBIT\",\"transaction_type\":\"WIRE\",\"bai_type_code\":\"506\",\"transaction_description\":\"190911041146 000004765495700 MIDCAP BUSINESS CREDIT LLC CONCENTRATION ACCOUNT 433 S MAIN ST STE 212 WEST HA RTFORD CT US 06110-2812 OBI=ACCOUNT TRANSFER /FTR/ Completed Timestamp 190911083038 (Time Released)\",\"transaction_amount\":163649.84,\"zero_day_float\":0.00,\"one_day_float\":0.00,\"two_date_float\":0.00,\"transaction_status\":\"COMPLETE\"},{\"posting_date\":\"2019-09-11\",\"value_date\":\"2019-09-11\",\"transaction_datetime\":\"2019-09-11 12:26:22Z\",\"debit_credit_indicator\":\"CREDIT\",\"transaction_type\":\"WIRE\",\"bai_type_code\":\"195\",\"transaction_description\":\"0911D4B74G1C000114 0911D4B74G1C000114 190911030824 044000024 HUNTINGTON NATIONAL BANK THE HUNTINGTON CENTER 41 S HIGH STREET COLUMBUS, OHIO 20190 91100000810 ORG=ROYAL ICE CREAM CO AKA PIERRES FRENCH ICE CREAM COMP 6200 EUCLID AVE CLEVELAND  OH 44103 OBI=REF: FBO ROYAL ICE CREAM COMPANY DBA PIERRES ICE CREAM CO OPI=01668343962 /FTR/ BNF=4764506150 MIDCAP BUSINESS CREDIT LLC FBO ROYAL ICE CREAM 433 SOUTH MAIN ST WEST HARTFORD CT 06110 Completed Timestamp 190911072613 (Time Released)\",\"transaction_amount\":163108.42,\"zero_day_float\":0.00,\"one_day_float\":0.00,\"two_date_float\":0.00,\"transaction_status\":\"COMPLETE\"}]},{\"bank_id\":\"111111111\",\"account_number\":\"3333333333\",\"account_type\":\"DEMAND_DEPOSIT\",\"account_name\":\"MIDCAP BUSINESS CREDIT LLC\",\"currency_code\":\"USD\",\"transaction_count\":3,\"transactions\":[{\"posting_date\":\"2019-09-11\",\"value_date\":\"2019-09-11\",\"transaction_datetime\":\"2019-09-11 16:08:56Z\",\"debit_credit_indicator\":\"DEBIT\",\"transaction_type\":\"ACH\",\"bai_type_code\":\"455\",\"transaction_description\":\"COMPANY NAME:  CLIENT ANALYSIS                    SRVC CHRG ENTRY DESC:    SRVC CHRG RECIPIENT ID:   SVC CHGE 0819 RECIPIENT NAME:000004744710146 COMPANY ID:    DP10700543 ENTRY CLASS CODE:   PPD DISCRETIONARY DATA: TRANSACTION CODE: 27\",\"transaction_amount\":252.53,\"zero_day_float\":0.00,\"one_day_float\":0.00,\"two_date_float\":0.00,\"customer_reference_number\":\"091000018761979\",\"transaction_status\":\"RECEIVED\"},{\"posting_date\":\"2019-09-11\",\"value_date\":\"2019-09-11\",\"transaction_datetime\":\"2019-09-11 13:30:13Z\",\"debit_credit_indicator\":\"DEBIT\",\"transaction_type\":\"WIRE\",\"bai_type_code\":\"506\",\"transaction_description\":\"190911040915 000004765495700 MIDCAP BUSINESS CREDIT LLC CONCENTRATION ACCOUNT 433 S MAIN ST STE 212 WEST HA RTFORD CT US 06110-2812 OBI=ACCOUNT TRANSFER /FTR/ Completed Timestamp 190911083005 (Time Released)\",\"transaction_amount\":39882.09,\"zero_day_float\":0.00,\"one_day_float\":0.00,\"two_date_float\":0.00,\"transaction_status\":\"COMPLETE\"},{\"posting_date\":\"2019-09-11\",\"value_date\":\"2019-09-11\",\"transaction_datetime\":\"2019-09-11 12:06:08Z\",\"debit_credit_indicator\":\"CREDIT\",\"transaction_type\":\"WIRE\",\"bai_type_code\":\"206\",\"transaction_description\":\"190911029133 000004126195569 PROFUSION INDUSTRIES, LLC 822 KUMHO DR STE 202 FAIRLAWN OH US 44333-8334 OBI=P ROFUSION INDUSTRIES LLC /FTR/ Completed Timestamp 190911070601 (Time Released)\",\"transaction_amount\":39358.40,\"zero_day_float\":0.00,\"one_day_float\":0.00,\"two_date_float\":0.00,\"transaction_status\":\"COMPLETE\"}]}],\"limit\":50,\"total_count\":6,\"paging\":[{}]}", headers: {})
    stub_request(:post, "https://api-sandbox.wellsfargo.com/token?grant_type=client_credentials&scope=TM-Transaction-Search").
        with(
            headers: {
                'Accept' => '*/*',
                'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                'Authorization' => 'Basic aW52YWxpZDppbnZhbGlk',
                'Content-Type' => 'application/x-www-form-urlencoded',
                'Host' => 'api-sandbox.wellsfargo.com',
                'User-Agent' => 'Ruby'
            }).
        to_return(status: 401, body: "Unauthorized", headers: {})
  end

  # This option will default to `:apply_to_host_groups` in RSpec 4 (and will
  # have no way to turn it off -- the option exists only for backwards
  # compatibility in RSpec 3). It causes shared context metadata to be
  # inherited by the metadata hash of host groups and examples, rather than
  # triggering implicit auto-inclusion in groups with matching metadata.
  config.shared_context_metadata_behavior = :apply_to_host_groups

# The settings below are suggested to provide a good initial experience
# with RSpec, but feel free to customize to your heart's content.
=begin
  # This allows you to limit a spec run to individual examples or groups
  # you care about by tagging them with `:focus` metadata. When nothing
  # is tagged with `:focus`, all examples get run. RSpec also provides
  # aliases for `it`, `describe`, and `context` that include `:focus`
  # metadata: `fit`, `fdescribe` and `fcontext`, respectively.
  config.filter_run_when_matching :focus

  # Allows RSpec to persist some state between runs in order to support
  # the `--only-failures` and `--next-failure` CLI options. We recommend
  # you configure your source control system to ignore this file.
  config.example_status_persistence_file_path = "spec/examples.txt"

  # Limits the available syntax to the non-monkey patched syntax that is
  # recommended. For more details, see:
  #   - http://rspec.info/blog/2012/06/rspecs-new-expectation-syntax/
  #   - http://www.teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
  #   - http://rspec.info/blog/2014/05/notable-changes-in-rspec-3/#zero-monkey-patching-mode
  config.disable_monkey_patching!

  # This setting enables warnings. It's recommended, but in some cases may
  # be too noisy due to issues in dependencies.
  config.warnings = true

  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = "doc"
  end

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  config.profile_examples = 10

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed
=end

end
