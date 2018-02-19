require "./logger"

module Litmus
  # Options class. Keeps default options in one place.
  class Options
    property logger         = Logger.default
    property basedir        = "."
    property outdir         = Dir.current
    property codedir        = Dir.current
    property input_files    = [] of String
    property recursive_dirs = [] of String
    property? help          = false
    property? update        = false
    property? generate      = false
    property verbosity      = 2
    property! help_text : String?

    def initialize
    end

    # Validates options.
    def validate!
      # set log level since this function might use it
      @logger.log_level(@verbosity)

      # don't validate when help was requested.
      if @help
        return
      end

      validate_input_files!
      validate_dirs!
    end

    # check for duplicate input files and send a warning.
    private def validate_input_files!
      validated = [] of String

      @input_files.reduce({} of String => Bool) do |duplicate, cur|
        if duplicate[cur]? == false
          duplicate[cur] = true
        else
          duplicate[cur] = false
          validated << cur
        end

        duplicate
      end.select do |file, duplicate|
        duplicate == true
      end.each do |file, _|
        @logger.warn "Input file '#{file}' was specified multiple times as "\
          "argument, but it will only be parsed once."
      end

      @input_files = validated
    end

    # Validate directories
    private def validate_dirs!
      unless Dir.exists? @basedir
        raise "Basedir '#{@basedir}' doesn't exist or isn't a directory."
      end

      unless Dir.exists? @outdir
        raise "Outdir '#{@outdir}' doesn't exist or isn't a directory."
      end

      unless Dir.exists? @codedir
        raise "Codedir '#{@codedir}' doesn't exist or isn't a directory."
      end
    end
  end
end
