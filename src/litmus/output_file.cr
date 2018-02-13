require "markd"
require "./partial"

module Litmus
  class OutputFile
    getter :path, :ast, :partials

    @path = uninitialized String
    @ast  = uninitialized Markd::Node
    @partials = uninitialized Array(Partial)

    def initialize(@path, @ast, @partials)
      transform!
    end

    # Transforms the AST to generate and output file.
    private def transform!
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
        puts "#{node.type}, #{partial.source}"
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
