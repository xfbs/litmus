require "./renderer"

module Litmus
  class MarkdownRenderer < Renderer
    class CodeBlock < Formatter
      def format(text)
        "#{"    " * @depth}#{text}"
      end
    end

    class BlockQuote < Formatter
      def format(text)
        "#{"> " * @depth}#{text}"
      end
    end

    class Heading < Formatter
      def format(text)
        "#{"#" * @depth} #{text}"
      end

      def leave; 0; end
    end

    class BulletList < Formatter
      def format(text)
        "#{"    " * (@depth - 1)}- #{text}"
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

    node Type::BlockQuote do |action, render|
      action.before do |node|
        render.pad!
        render.enter BlockQuote.new
      end

      action.after do |node|
        render.leave BlockQuote
        render.pad(2)
      end
    end

    node Type::Heading do |action, render|
      action.before do |node|
        render.pad!
        level = node.data["level"]?
        level = 1 unless level.is_a? Int32
        render.enter Heading.new(level)
      end

      action.after do |node|
        render.leave Heading
        render.pad(2)
      end
    end

    node Type::Text do |action, render|
      action.before do |node|
        render.format! node.text
      end
    end

    node Type::Paragraph do |action, render|
      action.before do |node|
        render.pad!
      end

      action.after do |node|
        render.pad(2)
      end
    end

    node Type::List do |action, render|
      action.before do |node|
        #render.pad!
        render.enter BulletList.new
      end

      action.after do |node|
        render.leave BulletList
        render.pad(2)
      end
    end

    node Type::Item do |action, render|
      action.before do |node|
        render.pad!
      end

      action.after do |node|
        render.pad(1)
      end
    end
  end
end

