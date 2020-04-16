require "metalogger/version"
require "logger"
require "time"
require "json"

module Metalogger
  class Meta
    THREAD_NAMESPACE = :_metalogger_meta.freeze

    def self.instance
      Thread.current[THREAD_NAMESPACE] ||= new
    end

    def self.add(*args)
      self.instance.add(*args)
    end

    def self.remove(*args)
      self.instance.remove(*args)
    end

    def self.reset(*args)
      self.instance.reset(*args)
    end

    def self.snapshot(*args)
      self.instance.snapshot(*args)
    end

    def self.with(*args, &block)
      self.instance.with(*args, &block)
    end

    def add(*objects)
      objects.each do |object|
        hash.merge!(object.to_hash)
      end
      expire
      self
    end

    def remove(*keys)
      keys.each do |key|
        hash.delete(key)
      end
      expire
      self
    end

    def reset
      hash.clear
      expire
      self
    end

    def replace(hash)
      @hash = hash
      expire
      self
    end

    def snapshot
      @snapshot ||= hash.clone
    end

    def with(*objects)
      current = hash.clone

      begin
        add(*objects)
        yield
      ensure
        replace(current)
      end
    end

    private

    def expire
      @snapshot = nil
    end

    def hash
      @hash ||= initial_hash
    end

    def initial_hash
      {pid: $$}
    end
  end

  class Entry
    SEVERITY_MAP = {
      "INFO" => "info",
      "DEBUG" => "debug",
      "WARN" => "warn",
      "ERROR" => "error",
      "FATAL" => "fatal",
      "UNKNOWN" => "unknown"
    }.freeze

    def initialize(severity, time, progname, message, meta_snapshot)
      @severity = SEVERITY_MAP.fetch(severity)
      @time = time
      @progname = progname
      @message = message
      @meta = meta_snapshot
    end

    def to_hash
      hash = {
        level: @severity,
        timestamp: @time.iso8601
      }

      if @message.is_a?(Hash)
        hash.merge!(@message)
      else @message.is_a?(String)
        hash[:message] = @message.is_a?(String) ? @message : @message.inspect
      end

      if !@progname.nil? && @progname.length > 0
        hash[:progname] = @progname
      end 

      hash[:meta] = @meta if !@meta.nil? && @meta.length > 0

      hash
    end

    def to_json
      to_hash.to_json
    end
  end

  class Formatter
    private

    def build_entry(severity, time, progname, message)
      Entry.new(severity, time, progname, message, Meta.snapshot)
    end
  end

  class LogfmtFormatter < Formatter
    ATTRIBUTE_SEPARATOR = " ".freeze
    KEY_VAL_SEPARATOR = "=".freeze
    KEY_SEPARATOR = ".".freeze
    ESCAPE_REGEX = /["\\]/.freeze
    DOUBLE_QUOTE = "\"\"".freeze
    ESCAPE_CHAR = "\\$&".freeze
    QUOTE = "\"".freeze

    def call(*args)
      entry = build_entry(*args).to_hash
      output = ""

      flatten(entry).sort().each do |key, val|
        output << ATTRIBUTE_SEPARATOR if output.length > 0
        
        val = val.to_s
        val = val.gsub(ESCAPE_REGEX, ESCAPE_CHAR) if val.include?("\"") || val.include?("\\")
        val = "#{QUOTE}#{val}#{QUOTE}" if val.include?(" ") || val.include?("=")
        val = DOUBLE_QUOTE if val.nil? || val.length <= 0

        output << "#{key}#{KEY_VAL_SEPARATOR}#{val}"
      end

      output << "\n"
    end

    private

    def flatten(entry, keys = "")
      hash = {}

      entry.each do |key, val|
        key = keys.length <= 0 ? "#{key}" : "#{keys}#{KEY_SEPARATOR}#{key}"

        if val.is_a?(Hash)
          hash.merge!(flatten(val, key))
        else
          hash[key] = val
        end
      end

      hash
    end
  end

  class JSONFormatter < Formatter
    def call(*args)
      entry = build_entry(*args)
      output = ""
      output << entry.to_json
      output << "\n"
    end
  end

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
