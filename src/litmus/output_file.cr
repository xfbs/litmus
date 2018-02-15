require "markd"
require "./partial"

module Litmus
  class OutputFile
    getter :path, :ast, :partials

    @path = uninitialized String
    @ast  = uninitialized Markd::Node
    @partials = uninitialized Array(Partial)

    def initialize(@path, @ast, @partials)
    end

    # Transforms the AST to generate and output file.
    def transform!
      known_nodes = {} of Markd::Node => Partial
      partials.each do |partial|
        known_nodes[partial.node] = partial
      end

      to_transform = [] of Tuple(Markd::Node, Partial)
      walker = @ast.walker
      while state = walker.next
        current, entering = state

        # check if this is a known node
        if partial = known_nodes[current]?
          to_transform << {current, partial}
        end
      end

      to_transform.each do |node, partial|
        fix_up(node, partial)
      end
    end

    private def fix_up(node : Markd::Node, partial : Partial)
      transformed = partial.to_markdown

      if transformed
        replace(node, transformed)
      else
        node.unlink
      end
    end

    # Replaces one node with another.
    # TODO: add this to Markd::Node?
    def replace(old : Markd::Node, new : Markd::Node)
      new.next = old.next?
      new.prev = old.prev?
      new.parent = old.parent

      if prev = old.prev?
        prev.next = new
      else
        new.parent?.try {|parent| parent.first_child = new}
      end

      if nextn = old.next?
        nextn.prev = new
      else
        new.parent?.try {|parent| parent.last_child = new}
      end
    end

    # Generates a new markdown file, which is the same as the input file
    # except it has been processed.
    def to_s(io)
      renderer = MarkdownRenderer.new
      renderer.render(@ast).to_s(io)
    end
  end
end
