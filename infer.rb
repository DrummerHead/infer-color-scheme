#!/usr/bin/env ruby


# Get the file, handle not providing an argument error
#

args = ARGF.argv

if args[0]
  file_path = args[0]
else
  puts "\nError\n"
  puts "\nYou must specify a file to be analyzed as an argument\n"
  puts "For example:\n"
  puts "./infer.rb test-css/main.css\n\n"
  exit
end

file_name = file_path.match(/^[^\/]*\/([^\.]*)\..*$/)[1]

test_css = File.read(file_path)
output_html = File.read("template-html/index.html")


# Old code that does not take into account CSS structure
#
=begin
hex_colors = test_css.scan(/(#[\da-f]{3})([\da-f]{3})?/).map{ |x, y| x + (y || '') }.uniq.sort
rgba_colors = test_css.scan(/rgba?\([^)]*\)/).sort;
=end


# Remove css comments and "one-linearize" the CSS for easier parsing
#

single_line_css = test_css.gsub(/\/\*.*?\*\//m){}.gsub(/[\n\r\t]/){}.gsub(/  */){' '}

# Separate media queries from non-media queries
#
media_regex = /@media ?\([^)]*\) ?{.*?}[\r\n\s]*}/
store_media = single_line_css.scan(media_regex)
single_line_css.gsub!(media_regex){}


# Test shit
#

=begin
p single_line_css
puts "\n\n==============\n\n"
store_media.each do |coso|
  p coso
  puts "\n\n======\n\n"
end
puts "\n\n==============\n\n"
p single_line_css == store_media
=end


# Function for analyzing a string of css without medias and converting it into a
# hash structure
#

def css_to_hash(css)
  hash = {}
  css.scan(/ ?(?<!@)([^{]*?) ?{([^}]*)}/) do |selector, content|
    hash[selector] = Hash[content.scan(/ ?([^:]*) ?: ?([^;]*) ?;/)]
  end
  return hash
end


def media_to_hash(media_css_array)
  hash = {}
  media_css_array.each do |media|
    media.scan(/(@media ?\([^)]*\)) ?{(.*?})[\r\n\s]*}/) do | media_declaration, block |
      hash[media_declaration] = css_to_hash(block)
    end
  end
  return hash
end

css_hash = css_to_hash(single_line_css)
css_media_hash = media_to_hash(store_media)



puts "\n\n==============\n\n"

def css_hash_to_json(css_hash)
  hash = {}
  hex_color_regex = /(#[\da-f]{3})([\da-f]{3})?/

  css_hash.each do | selector, block |
    block.each do | property, value |
      if value =~ hex_color_regex
        color_from_value = value.scan(hex_color_regex).map{ |x, y| x + (y || '')}[0]
        if hash[color_from_value] == nil
          hash[color_from_value] = []
        end
        hash[color_from_value] << "#{selector.gsub(/[\s]*,[\s]*/){",\n"}.gsub(/'/m){'"'}} {\n  #{property}: #{value};\n}"
        #json_string << "'#{value.scan(hex_color_regex).map{ |x, y| x + (y || '')}[0]}' : '#{selector.gsub(/[\s]*,[\s]*/){",\n"}.gsub(/'/m){'"'}} {\n  #{property}: #{value};\n}', "
      end
    end
  end
  json_string = hash.to_s.gsub(/=>/){" : "}
end

puts css_hash_to_json(css_hash)

puts "\n\n==============\n\n"


# Test shit
#

puts "\n\n==============\n\n"
css_hash.each do |ho, he|
  p ho
  p he
  p ""
end


puts "\n\n==============\n\n"
css_media_hash.each do |ho, he|
  p ho
  he.each do |ho, he|
    p ho
    p he
    p ""
  end
  puts "=-=-=-=-=-=-=-=-=-=-=-"
  p ""
end



# Old code, replace shit from template html file for creating a new one with the data
#
new_script = "var hexColors = #{css_hash_to_json(css_hash)}"

output_html.gsub!('{{title}}'){ file_name + '.css' }
output_html.gsub!('<!--{{script}}-->'){ "<script>\n#{new_script}\n</script>" }


File.write("output/#{file_name}.html", output_html)

puts "\n\nAn HTML with the inferred color scheme has been generated at `output/#{file_name}.html`\n\n"
=begin
new_script = "var hexColors = #{hex_colors.inspect};\nvar rgbaColors = #{rgba_colors};"

output_html.gsub!('{{title}}'){ file_name + '.css' }
output_html.gsub!('<!--{{script}}-->'){ "<script>\n#{new_script}\n</script>" }


File.write("output/#{file_name}.html", output_html)

puts "\n\nAn HTML with the inferred color scheme has been generated at `output/#{file_name}.html`\n\n"
=end
