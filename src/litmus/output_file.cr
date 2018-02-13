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
        delete(node)
      end
    end

    def replace(node : Markd::Node, replacement : Markd::Node)
      replacement.next = node.next
      replacement.prev = node.prev
      replacement.parent = node.parent

      if node == node.parent.first_child?
        node.parent.first_child = replacement
      end

      if node == node.parent.last_child?
        node.parent.last_child = replacement
      end

      if prev = node.prev
        prev.next = replacement
      end

      if next_node = node.next
        next_node.prev = replacement
      end
    end

    def delete(node : Markd::Node)
      if node == node.parent.first_child?
        node.parent.first_child = node.next
      end

      if node == node.parent.last_child?
        node.parent.last_child = node.prev
      end

      if prev = node.prev
        prev.next = node.next
      end

      if next_node = node.next
        next_node.prev = node.prev
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
