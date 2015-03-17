require 'menu_txt/version'
require 'menu_txt/node'
require 'menu_txt/simple_node'

module MenuTxt
  module_function

  LINE_REGEXP = /\A(-*)\s*([^\|]+)\s*\|\s*(.+)\Z/.freeze
  BLANK_REGEXP = /\A[[:space:]]*\z/.freeze

  def parse_path(path, root = SimpleNode.new(nil))
    File.open(path, 'r') { |file| parse(file, root) }
  end

  def parse(io, root = SimpleNode.new(nil))
    current_node = root

    io.each_line do |line|
      next if BLANK_REGEXP === line
      indent, name, url = line.match(LINE_REGEXP).captures.map(&:strip)
      current_node_indent_size = current_node.level + 1

      if (indent.size - current_node_indent_size) > 1
        raise "Can only nest submenus 1 level at a time: (#{line})"
      elsif indent.size > current_node_indent_size
        current_node = current_node.children.last
        current_node.add_child(name, url)
      elsif indent.size < current_node_indent_size
        unindents_count = current_node_indent_size - indent.size
        unindents_count.times { current_node = current_node.parent }
        current_node.add_child(name, url)
      else
        current_node.add_child(name, url)
      end
    end

    root
  end
end
