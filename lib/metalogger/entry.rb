require "json"

module Metalogger
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
        hash[:message] = @message
      else
        hash[:message] = @message.inspect
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
end
