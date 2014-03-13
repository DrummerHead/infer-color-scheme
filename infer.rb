#!/usr/bin/env ruby

args = ARGF.argv

file_path = args[0]
file_name = file_path.match(/^[^\/]*\/([^\.]*)\..*$/)[1]

test_css = File.read(file_path)
output_html = File.read("template-html/index.html")

hex_colors = test_css.scan(/(#[\da-f]{3})([\da-f]{3})?/).map{ |x, y| x + (y || '') }.uniq.sort
rgba_colors = test_css.scan(/rgba?\([^)]*\)/).sort;

new_script = "var hexColors = #{hex_colors.inspect};\nvar rgbaColors = #{rgba_colors};"

output_html.gsub!('{{title}}'){ file_name + '.css' }
output_html.gsub!('<!--{{script}}-->'){ "<script>\n#{new_script}\n</script>" }


File.write("output/#{file_name}.html", output_html)

puts "\n\nAn HTML with the inferred color scheme has been generated at `output/#{file_name}.html`\n\n"
