require 'vcr'
require 'webmock/rspec'

VCR.configure do |config|
  config.hook_into :webmock
  config.default_cassette_options = {
    decode_compressed_response: true
  }
  config.cassette_library_dir = File.join(
    File.dirname(__FILE__), '..', 'fixtures', 'vcr_cassettes'
  )
  config.filter_sensitive_data('<ACCUWEATHER_API_KEY>') do
    ENV.fetch('ACCUWEATHER_API_KEY', 'hidden')
  end
end
