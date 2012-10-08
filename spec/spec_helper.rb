require 'fakefs/spec_helpers'

RSpec.configure do |config|
  config.before do
    FakeFS.activate!
  end

  config.after do
    Dir['/**/'].sort.reverse.each { |dir| Dir.rmdir(dir) }
    FakeFS.deactivate!
  end
end