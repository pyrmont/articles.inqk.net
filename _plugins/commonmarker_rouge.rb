require 'rouge'

Jekyll::Hooks.register :site, :after_init do |site|
  rouge = Proc.new do |doc|
            doc.walk do |node|
              if node.type == :code_block
                kind = node.fence_info.split('-').first
                code = node.string_content
                formatter = Rouge::Formatters::HTMLLinewise.new(
                              Rouge::Formatters::HTML.new,
                              class_format: 'line-%i')
                lexer = Rouge::Lexer.find_fancy(kind) ||
                        Rouge::Lexers::PlainText.new
                html = '<div class="code highlight language-' +
                       node.fence_info +
                       '">' +
                       formatter.format(lexer.lex(code)) +
                       '</div>'
                new_node = ::CommonMarker::Node.new(:html)
                new_node.string_content = html
                node.insert_before(new_node)
                node.delete
              end
            end
          end
  CommonMarker::Plugins.add(rouge)
end