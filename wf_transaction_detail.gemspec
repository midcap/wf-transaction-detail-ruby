lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name = %q{wf_transaction_detail}
  s.version = "0.0.1"
  s.authors = ["Joe Elizondo"]
  s.email = ["jelizondo@midcap.com"]
  s.date = %q{2019-08-12}
  s.summary = %q{Wells Fargo Transaction Detail SDK for Ruby}
  s.license = "MIT"

  s.files = [
    "lib/transaction_collection.rb",
    "lib/account_collection.rb",
    "lib/http_client.rb",
    "lib/http_error.rb",
    "lib/wf_transaction_detail.rb",
  ]
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'activesupport'
  s.add_development_dependency "bundler", "~> 2.0"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "rspec", "~> 3.0"
  s.add_development_dependency 'webmock'
end
