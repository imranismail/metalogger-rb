require "time"
require "metalogger/meta"
require "metalogger/entry"

module Metalogger
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
        val = DOUBLE_QUOTE if val.length <= 0

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
end