require "logger"

module Litmus
  class Logger < Logger
    @@default_logger : Logger? = nil

    def self.default : Logger
      unless @@default_logger
        logger = Logger.new(STDERR)

        logger.formatter = Logger::Formatter.new do |sev, time, prog, msg, io|
          prefix =
            case sev
            when Logger::Severity::DEBUG then "Debug: "
            when Logger::Severity::INFO then ""
            when Logger::Severity::WARN then "Warning: "
            when Logger::Severity::ERROR then "Error: "
            when Logger::Severity::FATAL then "Fatal: "
            else ""
            end

          padding = " " * prefix.size

          first = true
          Logger.split_string(msg, 80 - prefix.size) do |rng|
            if first
              io << prefix
              first = false
            else
              io << "\n"
              io << padding
            end

            io << msg[rng]
          end
        end

        @@default_logger = logger
      end

      @@default_logger.not_nil!
    end

    def self.split_string(msg, width)
      pos = 0

      while pos < msg.size
        last = [pos + width, msg.size].min
        last = last
          .downto(pos + 1)
          .find(if_none: last){|p| !msg[p]?.try{|c| !c.ascii_whitespace?}}

        yield pos...last

        pos = last

        while msg[pos]? == ' '
          pos += 1
        end
      end
    end

    def fatal(e : Exception)
      if debug?
        fatal(String.build do |io|
          e.inspect_with_backtrace(io)
        end.chomp)
      else
        fatal e.message
      end
    end

    def log_level(n)
      self.level = Severity.new(n)
    end
  end
end
