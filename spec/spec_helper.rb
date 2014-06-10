
require_relative '../lib/medusa'

Dir.glob(Pathname.new(__FILE__).dirname.join("support/*.rb")).each { |f| require f }

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
end

# Setup logging into log/test.log
test_log = Pathname.new(__FILE__).dirname.join("../log/test.log")
Dir.mkdir(test_log.dirname.to_s) unless File.exist?(test_log.dirname.to_s)
Medusa.logger = Medusa::Logger.new(test_log.to_s)
