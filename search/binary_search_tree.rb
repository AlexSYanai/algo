module TreeBuilder
	class << self
		def build_tree(tree,array)
			tree.ary = array.map { |i| insert_node(tree,i) }
		end

		def insert_node(tree,value)
			tree.root.nil? ? tree.root = Node.new(value) : tree.root.link(value)
		end
	end
end

class Node
	attr_accessor :left_child, :right_child, :value
	def initialize(value,left_child=nil,right_child=nil)
		@value = value
		@left_child = left_child
		@right_child = right_child
	end
	
	def link(value)
		if value < self.value
			self.left_child.nil? ? self.left_child = Node.new(value) : self.left_child.link(value)
		elsif self.value < value
			self.right_child.nil? ? self.right_child = Node.new(value) : self.right_child.link(value)
		else
			return self
		end
	end
end

class BinaryTree
	attr_accessor :root,:ary
	def initialize(root=nil)
		@root = Node.new(root)
		@ary = []
	end

	def print_whole_tree
		@ary.each {|i| puts "#{i} value #{i.value unless i.nil?} #{i.left_child.value unless i.left_child.nil?} #{i.right_child.value unless i.right_child.nil?}"}
	end

	def print_found_node(node)
		node.nil? ? (puts "Target not found") : (puts "Value: #{node.value unless node.value.nil?} found at: #{node}")
	end

	def breadth_first_search(target)
		print_found_node(breadth_first(target))
	end

	def depth_first_search(target)
		print_found_node(depth_first(target))
	end

	def breadth_first(target)
    queue = [@root]
    until queue.empty?
      current_node = queue.shift
      return current_node if current_node.value == target
      queue.unshift(current_node.left_child) unless current_node.left_child.nil?
      queue.unshift(current_node.right_child) unless current_node.right_child.nil?
    end
    nil
  end

  def depth_first(target)
    stack = [@root]
    until stack.empty?
      current_node = stack.pop
      return current_node if current_node.value == target
      stack << current_node.left_child unless current_node.left_child.nil?
      stack << current_node.right_child unless current_node.right_child.nil?
    end
    nil
  end
end

tree_array = [28,22,32,38,21,11,26,36]
root = tree_array[0]
btree = BinaryTree.new(root)
btree_array = TreeBuilder.build_tree(btree,tree_array)
btree.print_whole_tree
btree.breadth_first_search(38)
btree.breadth_first_search(66)
btree.depth_first_search(32)