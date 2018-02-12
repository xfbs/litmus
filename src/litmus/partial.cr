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
		@attr = uninitialized Array(String)

    # which tags does this partial have? tags are any attributes specified
    # with a leading '#'
		@tags = uninitialized Array(String)

    # which modes does this partial have? modes are any attributes specified
    # with a leading '!'
		@mode = uninitialized Array(String)

    # body of the partial, containing code.
		@body = uninitialized String

		# where in the resulting codefile is this partial placed?
		property dest : Range(Int32, Int32)? = nil

    property hidden = false
    property after : Array(String)? = nil
    property before : Array(String)? = nil
    property replace : Array(String)? = nil

		def initialize(@node, @source)
			@attr = @node.fence_language.split(' ')
			@body = @node.text
      parse_attrs!
		end

    def parse_attrs!
      puts @attr.inspect
      @attr.each_with_index do |a, i|
        case a[0]?
        when '@'
          if @file
            LOG.error "Multiple files specified for partial at #{source}, ignoring #{a}."
          else
            if i != 1
              LOG.warn "File specification for partial at #{source} is not after language name."
            end
            @file = a[1..-1]
          end
        when '!'
        when '#'
        else
          @lang = a if i == 0
        end
        #else
        #  @file = get_attrs("@")[0]?
        #  @tags = get_attrs("#")
        #  @mode = get_attrs("!")

        #  @hidden = @mode.includes? "hide"
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
		def set_dest(@range)
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
	end
end
