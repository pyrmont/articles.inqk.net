# frozen-string-literal: true

require 'rouge'

module CommonMarker
  module Plugin
    module SyntaxHighlighter
      def self.call(doc)
        doc.walk do |node|
          next unless node.type == :code_block

          new_node = CommonMarker::Node.new :html
          new_node.string_content = render(code: node.string_content,
                                           format: node.fence_info.split('-').first,
                                           lang: node.fence_info)
          node.insert_before new_node
          node.delete
        end
      end

      def self.render(code:, format:, lang:)
        formatter = Rouge::Formatters::HTMLLinewise.new(
                      Rouge::Formatters::HTML.new,
                      class_format: 'line-%i')
        lexer = Rouge::Lexer.find_fancy(format) ||
                Rouge::Lexers::PlainText.new
        lang_class = (lang == '') ? 'txt' : lang
        html = <<~HTML
                 <pre class="code highlight language-#{lang_class}">
                   #{formatter.format(lexer.lex(code))}
                 </pre>
               HTML
      end
    end
  end
end