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
	attr_accessor :leftchild, :rightchild, :value
	def initialize(value,leftchild=nil,rightchild=nil)
		@value = value
		@leftchild = leftchild
		@rightchild = rightchild
	end
	
	def link(value)
		if value < self.value
			self.leftchild.nil? ? self.leftchild = Node.new(value) : self.leftchild.link(value)
		elsif self.value < value
			self.rightchild.nil? ? self.rightchild = Node.new(value) : self.rightchild.link(value)
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

	def tb_print
		@ary.each {|i| puts "#{i} value #{i.value unless i.nil?} #{i.leftchild.value unless i.leftchild.nil?} #{i.rightchild.value unless i.rightchild.nil?}"}
	end
end

array_sorted = [28,22,32,38,21,11,26,36]
root = array_sorted[0]
btree = BinaryTree.new(root)
btree_array = TreeBuilder.build_tree(btree,array_sorted)
btree.tb_print
