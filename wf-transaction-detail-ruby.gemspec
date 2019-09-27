Gem::Specification.new do |s|
  s.name = %q{wf-transaction-detail-ruby}
  s.version = "0.0.1"
  s.authors = ["Joe Elizondo"]
  s.email = ["jelizondo@midcap.com"]
  s.date = %q{2019-08-12}
  s.summary = %q{Wells Fargo Transaction Detail SDK for Ruby}

  s.files = [
    "lib/http_client.rb",
    "lib/http_error.rb",
    "lib/transaction_collection.rb",
    "lib/account_collection.rb",
  ]

  s.require_paths = ["lib"]
  s.license = "MIT"
  s.add_runtime_dependency 'activesupport'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'webmock'
end
