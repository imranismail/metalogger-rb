require "test_helper"
require "stringio"

class MetaloggerTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Metalogger::VERSION
  end
end

class Metalogger::LoggerTest < Minitest::Test
  def setup
    @message = "A message"
    @output  = STDOUT
    @logger  = ::Metalogger::Logger.new(@output)
  end

  def test_log
    @logger.with_meta({name: "imran"}) { @logger.info("hello") }
    @logger.struct(:info, "hello", {name: "imran"})
    refute_nil ::Metalogger::VERSION
  end
end