require 'rouge'

Jekyll::Hooks.register :site, :after_init do |site|
  CommonMarker.plugins << CommonMarker::Plugin::FootnoteFixer
end

module CommonMarker
  module Plugin
    module FootnoteFixer

      BEFORE_HTML = '<span class="connector">&#65279;'
      AFTER_HTML = '</span>'

      def self.call(doc)
        doc.walk do |node|
          next unless node.type == :footnote_reference

          before = CommonMarker::Node.new :inline_html
          before.string_content = BEFORE_HTML
          after = CommonMarker::Node.new :inline_html
          after.string_content = AFTER_HTML

          node.insert_before before
          node.insert_after after
        end
      end
    end
  end
end

