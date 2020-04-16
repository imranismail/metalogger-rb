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

    def self.clear(*args)
      self.instance.clear(*args)
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

    def clear
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
      old_hash = hash.clone

      begin
        add(*objects)
        yield
      ensure
        replace(old_hash)
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
    def initialize(severity, time, progname, message, meta_snapshot)
      @severity = severity
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

      if !@progname.nil? || @progname.length > 0
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
    KEY_SEPARATOR = ".".freeze
    KEY_VAL_SEPARATOR = "=".freeze
    ATTRIBUTE_SEPARATOR = " ".freeze

    def call(*args)
      entry = build_entry(*args).to_hash
      output = ""

      flatten(entry).each do |key, val|
        output << ATTRIBUTE_SEPARATOR if output.length > 0
        
        val = val.to_s
        val = val.gsub(/["\\]/, "\\$&") if val.include?("\"") || val.include?("\\")
        val = "\"#{val}\"" if val.include?(" ") || val.include?("=")
        val = "\"\"" if val.nil? || val.length <= 0

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
      severity = SEVERITY_MAP[args[0]]
      message = args[1]
      object = args[2]

      if args.length == 3 && object.is_a?(Hash) && object.length > 0
        message = object.merge(message: message)
      end

      add(severity, message, @progname, &block)
    end

    def with_meta(*objects, &block)
      Metalogger::Meta.with(*objects, &block)
    end
  end
end
