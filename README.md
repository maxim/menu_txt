# menu_txt

[![Build Status](https://travis-ci.org/maxim/menu_txt.svg?branch=master)](https://travis-ci.org/maxim/menu_txt)
[![Code Climate](https://codeclimate.com/github/maxim/menu_txt/badges/gpa.svg)](https://codeclimate.com/github/maxim/menu_txt)


If you have non-technical people who want to be able to edit menus on your website, this is the gem for you.

## Quick Start

This gem doesn't require Rails, but seeing how it works with Rails should give you a good enough idea of how to use it.


### Syntax

Let's create a text file somewhere, say `app/menus/my_awesome_menu.txt`.

~~~plain
1st level thing 1 | /foo1

- 2nd level thing A | /foo1/bar1
-- 3rd level thing A | /foo1/bar1/baz1
-- 3rd level thing B | /foo1/bar1/baz2

- 2nd level thing B | /foo1/bar2
-- 3rd level thing A | /foo1/bar2/baz1

- 2nd level thing C | /foo1/bar3

1st level thing 2 | /foo2
~~~

Dashes in front are nesting levels, a pipe `|` separates text from url. Blank lines are ignored. That's all there is to know.


### Rails auto-reload

When you're in Rails it's best to put all the menus in one dir, because you could then add this line to `development.rb`.

~~~ruby
config.watchable_dirs['app/menus'] = [:txt]
~~~

It ensures that any changes to txt files in `app/menus` will reload your app, so you could see changes on a browser refresh.

### Menu class (model)

Create a class for your menu, it could just be another model in your rails app, so let's put it in `app/models/my_awesome_menu.rb`.

~~~ruby
MyAwesomeMenu = MenuTxt.parse_path('app/menus/my_awesome_menu.txt')
~~~

### HTML

Now we just need a partial that can render itself recursively for every submenu. For example, let's create `app/views/my_awesome_menu/_nodes.html.erb`.

~~~html
<% nodes.each do |node| %>
<li <%=raw node.leaf? ? '' : 'class="dropdown-submenu"' %>>
  <%= link_to node.name, node.url %>

  <% unless node.leaf? %>
  <ul class="dropdown-menu">
    <%= render 'my_awesome_menu/nodes', nodes: node.children %>
  </ul>
  <% end %>
</li>
<% end %>
~~~

Notice how I use `leaf?` above to determine if there are no more submenus under this node.

Finally, wherever you want to render this menu in your html, all you gotta do is the following.

~~~html
<ul class="dropdown-menu">
  <%= render 'my_awesome_menu/nodes', nodes: MyAwesomeMenu.children %>
</ul>
~~~

So given you have css/javascript hooked to classes `dropdown-menu` and `dropdown-submenu`, everything would just work. Now try editing `my_awesome_menu.txt` and refreshing the page. That's it, now your marketing people could edit the a plain text file on github and commit it without your involvement.

## Advanced usage

### Traversing nodes

The `MyAwesomeMenu` in the above example is fully `Enumerable` and if `each` is called without a block it returns a proper iterator. The order of iteration is exactly like reading the text file top to bottom.

### Extending nodes

If you want each node in your menu to have special methods, you can use your own node class. Simply create it kinda like this.

~~~ruby
class MySpecialMenuNode
  include MenuTxt::Node

  def highlight?
    url.include?('special_deals')
  end
end
~~~

The `MenuTxt::Node` is a convenient module that gives you all the node boilerplate. Then, when you create the menu model, you can pass your node object as the second argument, and it will become root of the menu, which acts as the prototype for all nested nodes.

~~~ruby
MyAwesomeMenu =
  MenuTxt.parse_path('app/menus/menu.txt', MySpecialMenuNode.new(nil))
~~~

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'menu_txt'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install menu_txt

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/maxim/menu_txt/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
