require "markd"

module Litmus
  class Renderer
    alias Type = Markd::Node::Type

    # Determines which actions to be taken before and after
    # encountering a node.
    class Actions
      getter :do_before, :do_after
      @do_before : Proc(Markd::Node, Nil)? = nil
      @do_after  : Proc(Markd::Node, Nil)? = nil

      def before(&@do_before : Proc(Markd::Node, Nil)); end
      def after(&@do_after : Proc(Markd::Node, Nil)); end

      def before(node : Markd::Node)
        if action = @do_before
          action.call(node)
        end
      end

      def after(node : Markd::Node)
        if action = @do_after
          action.call(node)
        end
      end
    end

    # Abstract class to define how to format text.
    abstract class Formatter
      property depth : Int32 = 1
      abstract def format(text)

      def initialize(depth : Int32? =nil)
        @depth = depth if depth
      end

      def enter
        @depth += 1
        @depth
      end

      def leave
        @depth -= 1 unless @depth == 0
        @depth
      end
    end

    property formatters = [] of Formatter
    property padding = 0

    @@actions = [] of Tuple(Markd::Node::Type, Proc(Actions, Renderer, Nil))
    @actions = {} of Markd::Node::Type => Actions
    @output = uninitialized IO::Memory

    # Create new renderer.
    def initialize
      @output = IO::Memory.new

      @@actions.each do |type, check|
        actions = Actions.new
        check.call(actions, self)
        @actions[type] = actions
      end
    end

    # Renders the given document using the methods provided.
    def render(document : Markd::Node)
      # walks all nodes, processing them.
      walker = document.walker
      while next_node = walker.next
        current, enter = next_node

        # process node
        if action = @actions[current.type]?
          action.before(current) if enter
          action.after(current)  if !enter
        else
          puts "can't handle #{current.type}"
        end
      end

      # return self so that calls can be chained.
      self
    end

    def format(line, fmt : Formatter? = nil)
      line = fmt.format(line) if fmt

      @formatters.reverse.each do |fmt|
        line = fmt.format(line)
      end

      line
    end

    def format!(text, fmt : Formatter? = nil)
      # format all lines
      lines = text.split("\n").map{|line| format(line, fmt)}

      lines[0..-2].each do |line|
        emit_nl! line
      end

      emit! lines[-1]
    end

    def emit!(data)
      @output << data
    end

    def emit_nl!(data)
      emit! data
      newline!
    end

    def newline!
      @output << "\n"
    end

    def enter(fmt)
      if last = @formatters[-1]?
        if last.class == fmt.class
          last.enter
        end
      else
        @formatters << fmt
      end
    end

    def leave(type)
      if last = @formatters[-1]?
        if last.class == type
          @formatters.pop unless last.leave > 0
        end
      else
        @formatters.pop
      end
    end

    def self.node(type, &block : Proc(Actions, Renderer, Nil))
      @@actions << {type, block}
    end

    def pad(n)
      @padding = n
    end

    def pad!
      if @padding > 0
        (@padding - 1).times do
          newline!
          format! ""
        end

        newline!
      end
      @padding = 0
    end

    # Generate string output of rendered document.
    def to_s
      @output.to_s
    end
  end
end
