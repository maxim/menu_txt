$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'menu_txt'
require 'minitest/autorun'

class TestMenuTxt < Minitest::Test
  def assert_node(node, options = {})
    assert_equal(options[:name],   node.name)   if options[:name]
    assert_equal(options[:url],    node.url)    if options[:url]
    assert_equal(options[:parent], node.parent) if options[:parent]
    assert_equal(options[:level],  node.level)  if options[:level]

    if options.key?(:leaf)
      if options[:leaf]
        assert(node.leaf?, "Expected \"#{node.name}\" to be a leaf node")
      else
        refute(node.leaf?, "Expected \"#{node.name}\" not to be a leaf node")
      end
    end
  end

  def test_simple_node_is_enumerable
    assert MenuTxt::SimpleNode.new(nil).is_a?(::Enumerable)
  end

  def test_parses_one_level_element
    menu = <<-TEXT
foo | http://example.org
TEXT

    root = MenuTxt.parse(menu)
    assert_equal 1, root.children.size

    node = root.children.first
    assert_node node,
      name: 'foo',
      url: 'http://example.org',
      leaf: true,
      parent: root,
      level: 0
  end

  def test_parses_2_elements_on_same_level
    menu = <<-TEXT
foo | http://example.org/foo
bar | http://example.org/bar
TEXT

    root = MenuTxt.parse(menu)
    assert_equal 2, root.children.size

    node1 = root.children[0]
    node2 = root.children[1]

    assert_node node1,
      name: 'foo',
      url: 'http://example.org/foo',
      leaf: true,
      parent: root,
      level: 0

    assert_node node2,
      name: 'bar',
      url: 'http://example.org/bar',
      leaf: true,
      parent: root,
      level: 0
  end

  def test_parses_2_nested_elements
    menu = <<-TEXT
foo | http://example.org/foo
- bar | http://example.org/bar
TEXT

    root = MenuTxt.parse(menu)
    assert_equal 1, root.children.size
    assert_equal 1, root.children.first.children.size
    assert_equal 2, root.each.count

    node1 = root.children[0]
    node2 = node1.children[0]

    assert_node node1,
      name: 'foo',
      url: 'http://example.org/foo',
      leaf: false,
      parent: root,
      level: 0

    assert_node node2,
      name: 'bar',
      url: 'http://example.org/bar',
      leaf: true,
      parent: node1,
      level: 1
  end

  def test_parses_3_nested_elements
    menu = <<-TEXT
foo | http://example.org/foo
- bar | http://example.org/bar
-- baz | http://example.org/baz
TEXT

    root = MenuTxt.parse(menu)
    assert_equal 1, root.children.size
    assert_equal 3, root.each.count

    node1 = root.children[0]
    node2 = node1.children[0]
    node3 = node2.children[0]

    assert_node node1,
      name: 'foo',
      url: 'http://example.org/foo',
      leaf: false,
      parent: root,
      level: 0

    assert_node node2,
      name: 'bar',
      url: 'http://example.org/bar',
      leaf: false,
      parent: node1,
      level: 1

    assert_node node3,
      name: 'baz',
      url: 'http://example.org/baz',
      leaf: true,
      parent: node2,
      level: 2
  end

  def test_parses_complex_menu
    menu = <<-TEXT
level 0 name 1 | level 0 url 1
- level 1 name 1 | level 1 url 1
-- level 2 name 1 | level 2 url 1
--- level 3 name 1 | level 3 url 1
level 0 name 2 | level 0 url 2
- level 1 name 2 | level 1 url 2
- level 1 name 3 | level 1 url 3
level 0 name 3 | level 0 url 3
TEXT

    root = MenuTxt.parse(menu)
    assert_equal 8, root.each.count
    nodes = root.each.to_a

    assert_node nodes[0],
      name: 'level 0 name 1',
      url: 'level 0 url 1',
      leaf: false,
      parent: root,
      level: 0

    assert_node nodes[1],
      name: 'level 1 name 1',
      url: 'level 1 url 1',
      leaf: false,
      parent: nodes[0],
      level: 1

    assert_node nodes[2],
      name: 'level 2 name 1',
      url: 'level 2 url 1',
      leaf: false,
      parent: nodes[1],
      level: 2

    assert_node nodes[3],
      name: 'level 3 name 1',
      url: 'level 3 url 1',
      leaf: true,
      parent: nodes[2],
      level: 3

    assert_node nodes[4],
      name: 'level 0 name 2',
      url: 'level 0 url 2',
      leaf: false,
      parent: root,
      level: 0

    assert_node nodes[5],
      name: 'level 1 name 2',
      url: 'level 1 url 2',
      leaf: true,
      parent: nodes[4],
      level: 1

    assert_node nodes[6],
      name: 'level 1 name 3',
      url: 'level 1 url 3',
      leaf: true,
      parent: nodes[4],
      level: 1

    assert_node nodes[7],
      name: 'level 0 name 3',
      url: 'level 0 url 3',
      leaf: true,
      parent: root,
      level: 0
  end

  def test_raises_error_when_nested_by_more_than_one_level
    menu = <<-TEXT
foo | example.org
-- bar | example.org
TEXT

    e = assert_raises RuntimeError do
      MenuTxt.parse(menu)
    end

    assert_match /nest submenus 1 level/, e.message
  end

  def test_makes_all_nodes_same_class_as_injected_root_node
    special_node = Class.new do
      include MenuTxt::Node
    end

    menu = <<-TEXT
foo | example.org
- bar | example.org
TEXT

    root = MenuTxt.parse(menu, special_node.new(nil))
    assert_kind_of special_node, root
    root.each do |node|
      assert_kind_of special_node, node
    end
  end
end
