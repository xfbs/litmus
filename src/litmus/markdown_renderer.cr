require "./renderer"

module Litmus
  class MarkdownRenderer < Renderer
    class CodeBlock < Formatter
      def format(text)
        "    #{text}"
      end
    end

    node Type::CodeBlock do |action, render|
      action.before do |node|
        render.pad!
        if node.fenced?
          render.format! "```#{node.fence_language}"
          render.newline!
          render.format! node.text.chomp
          render.newline!
          render.format! "```"
        else
          render.format! node.text.chomp, fmt: CodeBlock.new
        end
        render.pad(2)
      end
    end
  end
end

