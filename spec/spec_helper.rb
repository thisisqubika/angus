require 'bundler/setup'

require 'simplecov'
SimpleCov.start

require 'rspec'

require 'simplecov-rcov'
require 'simplecov-rcov-text'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::RcovFormatter,
  SimpleCov::Formatter::RcovTextFormatter
]

Dir[File.join(File.dirname(__FILE__), 'support', '**', '*.rb')].each { |f| require f }

RSpec.configure do |config|

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  config.around(:each) do |example|
    old_work_dir = Dir.pwd

    Dir.chdir(example.metadata[:work_dir] || old_work_dir)

    example.run

    Dir.chdir(old_work_dir)
  end

end