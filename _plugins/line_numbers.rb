Jekyll::Hooks.register :posts, :post_render do |post|
  post.output = post.output.gsub(/(<pre(?: class=".*?")?><code(?: class=".*?")?>)(.*?)(<\/code><\/pre>)/m) do |code_block|
    $1 + '<ul><li>' + $2.split("\n").join('</li><li>') + '</li></ul>' + $3
  end
end