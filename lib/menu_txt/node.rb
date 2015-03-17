module MenuTxt
  module Node
    include ::Enumerable

    def initialize(name, url = '')
      @name, @url, @parent, @children, @level = name, url, nil, [], -1
    end

    attr_reader :name, :url, :parent, :children, :level

    def leaf?; children.empty? end

    def traverse(&block)
      if block_given?
        yield(self) if parent

        children.each do |child|
          child.traverse(&block)
        end
      else
        enum_for
      end
    end
    alias_method :each, :traverse

    def add_child(name, url)
      self << self.class.new(name, url)
    end

    def <<(node)
      node.parent = self
      node.level = level + 1
      children << node
    end

    protected

    def level=(int)
      @level = int
    end

    def parent=(node)
      @parent = node
    end
  end
end
