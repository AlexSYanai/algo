module TreeBuilder
	class << self
		def build_tree(tree,input_array)
			tree.nodes = input_array.map { |val| insert_node(tree,val) }
		end

		def insert_node(tree,value)
			tree.root.nil? ? tree.root = Node.new(value) : tree.root.link(value)
		end
	end
end

module TreeSearcher
	class << self
		def breadth_first_search(target,root)
	    queue = [root]
	    until queue.empty?
	      current_node = queue.shift
	      return current_node if current_node.value == target
	      queue.unshift(current_node.left_child) unless current_node.left_child.nil?
	      queue.unshift(current_node.right_child) unless current_node.right_child.nil?
	    end
	    nil
	  end

	  def depth_first_search(target,root)
	    stack = [root]
	    until stack.empty?
	      current_node = stack.pop
	      return current_node if current_node.value == target
	      stack << current_node.left_child unless current_node.left_child.nil?
	      stack << current_node.right_child unless current_node.right_child.nil?
	    end
	    nil
	  end
	end
end

class Node
	attr_accessor :left_child,:right_child,:value
	def initialize(value,left_child=nil,right_child=nil)
		@value 			 = value
		@left_child  = left_child
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
	attr_accessor :root,:nodes
	def initialize(root=nil)
		@root  = Node.new(root)
		@nodes = []
	end

	def breadth_first_search(target)
		print_found_node(TreeSearcher.breadth_first_search(target,root),target)
	end

	def depth_first_search(target)
		print_found_node(TreeSearcher.depth_first_search(target,root),target)
	end

	def print_whole_tree
		nodes.each { |node| puts "#{node} value #{node.value unless node.nil?} #{node.left_child.value unless node.left_child.nil?} #{node.right_child.value unless node.right_child.nil?}" }
	end

	def print_found_node(node,target)
		node.nil? ? (puts "\nValue #{target} not found") : (puts "\nValue #{node.value unless node.value.nil?} found at: #{node}")
	end
end

seed_array = (20..40).to_a.shuffle
binary_tree = BinaryTree.new(seed_array[0])
binary_tree_array = TreeBuilder.build_tree(binary_tree,seed_array)
binary_tree.print_whole_tree
binary_tree.breadth_first_search(38)
binary_tree.breadth_first_search(66)
binary_tree.depth_first_search(32)