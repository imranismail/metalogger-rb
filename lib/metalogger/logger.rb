
require "metalogger/formatter"
require "logger"

module Metalogger
  class Logger < ::Logger
    SEVERITY_MAP = {
      info: Logger::Severity::INFO,
      debug: Logger::Severity::DEBUG,
      warn: Logger::Severity::WARN,
      error: Logger::Severity::ERROR,
      fatal: Logger::Severity::FATAL,
      unknown: Logger::Severity::UNKNOWN
    }.freeze

    def initialize(*args)
      super
      @formatter = Metalogger::LogfmtFormatter.new
    end

    def struct(*args, &block)
      severity, message, object = args
      severity = SEVERITY_MAP.fetch(severity)

      if args.length == 3 && object.is_a?(Hash) && object.length > 0
        message = object.merge(message: message)
      end

      add(severity, message, @progname, &block)
    end

    def with_meta(*args, &block)
      Metalogger::Meta.with(*args, &block)
    end

    def add_meta(*args)
      Metalogger::Meta.add(*args)
    end

    def reset_meta(*args)
      Metalogger::Meta.reset(*args)
    end

    def remove_meta(*args)
      Metalogger::Meta.remove_meta(*args)
    end
  end
end
