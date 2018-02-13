require "markd"
require "./input_file"

module Litmus
	# Represents a partial code fragment from a code block in a litmus file,
	# which is combined with other fragments (in the order specified in the
	# fragment itself) to generate a code file.
	class Partial
		getter :attr, :body, :tags, :mode, :node

    # markdown AST node that this partial comes from.
		@node = uninitialized Markd::Node

    # input file that this partial comes from.
    @source = uninitialized InputFile

    # which language is specified in the fenced block.
		property lang : String? = nil

    # which code file (filename) is this partial supposed to be a part of.
		property file : String? = nil

    # which attributes does this partial have? attributes are anything
    # specified after the language name in a fenced code block.
		property attr = [] of String

    # which tags does this partial have? tags are any attributes specified
    # with a leading '#'
		property tags = [] of String

    # which modes does this partial have? modes are any attributes specified
    # with a leading '!'
		property mode = [] of String

    # body of the partial, containing code.
		@body = uninitialized String

		# where in the resulting codefile is this partial placed?
		property dest : Range(Int32, Int32)? = nil

    property hidden = false
    property after : Array(String)? = nil
    property before : Array(String)? = nil
    property replace = false

		def initialize(@node, @source)
			@node.fence_language.split(' ') do |a|
        @attr << a unless a.size == 0
      end

			@body = @node.text
      parse_attrs!
      parse_modes!
		end

    def parse_attrs!(attr=@attr)
      attr.each_with_index do |a, i|
        rest = a[1..-1]
        case a[0]
        when '@'
          if @file
            LOG.error "Multiple files specified for partial at #{source}, ignoring #{a}."
          elsif rest.size == 0
            LOG.error "Illegal file name '#{rest}' specified for partial at #{source}, ignoring."
          else
            if i != 1
            LOG.warn "File specification for partial at #{source} is not after language name."
            end
            @file = rest
          end
        when '!'
          if rest.size == 0
            LOG.error "Empty mode specified for partial at #{source}, ignoring."
          else
            @mode << rest
          end
        when '#'
          if rest.size == 0
            LOG.error "Empty tag specified for partial at #{source}, ignoring."
          else
            @tags << rest
          end
        else
          @lang = a if i == 0
        end
      end
    end

    def parse_modes!(mode=@mode)
      mode.each do |m|
        case m
        when "hide"
          error_multiple_specification @hidden, "'hide' mode", "!#{m}"
          @hidden = true
        when /^after(#[^#]+)*$/
          error_multiple_specification @after, "'after' mode", "!#{m}"
          @after = m.split('#')[1..-1] unless @after
        when /^before(#[^#]+)*$/
          error_multiple_specification @before, "'before' mode", "!#{m}"
          @before = m.split('#')[1..-1] unless @before
        when "replace"
          error_multiple_specification @replace, "'replace' mode", "!#{m}"
          @replace = true
        else
          LOG.warn "Mode '#{m}' not recognized in partial at #{source}, ignoring."
        end
      end
    end

    # Print an error message if something has already been specified before.
    def error_multiple_specification(obj, what, item=nil)
      item = " '#{item}'" if item
      item = "" unless item
      if obj
        LOG.error "#{what} specified multiple times for partial at #{source}, ignoring#{item}."
      end
    end

		# Get an arbitrary attribute.
		def get_attrs(name)
			@attr
				.map{|a| a.match /^#{name}(.+)$/}
				.select{|a| !a.nil?}
				.map{|a| a.as(Regex::MatchData)[1]}
		end

		# Specify on which lines of the file this partial
		# gets rendered to.
		def set_dest(@dest)
		end

		# Turn this partial into a markdown code block.
		def to_markdown(io="")
			io << "###### [][#{file}]"
			io << ", lines #{@range.begin}-#{@range.end}"
			io << "\n\n"
			io << "```#{attr[0]? || ""}"
			io << body
			io << "```"
			io
		end

    # Returns a string denoting where this partial was found.
    def source
      "'#{@source.file}' lines #{@node.source_pos[0][0]}-#{@node.source_pos[1][0]}"
    end

    # Returns true if this partial is literate, false otherwise.
    def literate?
      @lang && @file
    end

    # Generates markdown from this partial
    def to_markdown
      return if @hidden

      io = IO::Memory.new
			options = Markd::Options.new(smart: true)

      io << "###### [#{@file}](#{@file})"

      if @dest
        io << ", lines #{@dest}"
      end

      io << "\n"

      io << "```#{@lang || ""}\n"
      io << @body
      io << "```"

      Markd::Parser.parse(io.to_s, options)
    end
	end
end
