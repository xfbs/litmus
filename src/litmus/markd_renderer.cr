require "markd"

module Litmus
  abstract class MarkdRenderer
    alias Node = Markd::Node
    alias Type = Markd::Node::Type
    alias Handler = Proc(Node, IO, Nil)

    @@handlers = {} of Type => Handler

    def initialize
    end

    def render(node : Node, output : IO = IO::Memory.new)
      loop do
        handler = @@handlers[node.type]
        handler.call(node, output)
        break unless node.next?
        node = node.next
      end

      output
    end

    def self.handle(node : Node, output : IO = IO::Memory.new)
      if handler = @@handlers[node.type]?
        handler.call(node, output)
      else
        puts "ignoring node type #{node.type}"
      end
      output
    end

    def self.handle(type : Type, &block : Handler)
      @@handlers[type] = block
    end

    def self.children(node : Node)
      if child = node.first_child?
        loop do
          yield child
          break unless child.next?
          child = child.next
        end
      end
    end

    def self.prefix(pfix : String, text, output : IO = IO::Memory.new)
      lines = text.to_s.split("\n").each_with_index do |line, i|
        output << "\n" unless i == 0
        output << pfix
        output << line
      end

      output
    end
  end
end
