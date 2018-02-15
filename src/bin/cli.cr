require "../litmus.cr"

begin
  Litmus::Cli.new.parse_args!.run!
rescue ex
  Litmus::Logger.default.fatal ex
end
