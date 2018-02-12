require "./litmus/*"
require "logger"

module Litmus
  LOG = Logger.new(STDERR)

  LOG.formatter = Logger::Formatter.new do |sev, time, prog, msg, io|
    case sev
    when Logger::Severity::DEBUG then io << "Debug: "
    when Logger::Severity::INFO then io << "Info: "
    when Logger::Severity::WARN then io << "Warning: "
    when Logger::Severity::ERROR then io << "Error: "
    when Logger::Severity::FATAL then io << "Fatal: "
    end
    io << msg
  end
end
