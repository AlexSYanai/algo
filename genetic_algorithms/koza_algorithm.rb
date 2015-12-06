#
# Koza's Algorithm in Ruby
# Based upon: Introduction to Genetic Algorithms Chapter 2 (Melanie Mitchell)
# 
# This is a Ruby implementation of John Koza's genetic programming algorithm,
# originally written in Lisp (1992). Parse trees are generated and, given a
# set of functions and terminal values, programs are then generated in order to
# automatically generate some expression. The trees are made up of functions, that
# represent syntactically correct programs: function nodes must have branches off
# of themselves equal to the number of inputs for that function and the subsequent 
# child nodes can either be terminal nodes or other functions. This means that, in
# theory, the trees have no defined size, but most implementations limit the depth.
# The function and terminal nodes need to be estimated for each algorithm since, by
# nature, the programmer doesn't really know what the output program will look like.
#
# This is a simple, illustrative example. Here, the functions are mathematical 
# operators and the terminal set consists :X, of an input, and :R, a randomly generated
# value within a given range, -5..5. The target function, x**2 + x + 1, a quadratic
# equation, is given, though obviously this wouldn't be the case generally. Fitness is
# measured based on how close a given program's outputs are to those of the target 
# function, given the same randomly generated inputs. This replicates real world examples,
# where the inputs and outputs would be known. Each generation, the population is altered
# via crossover(90%) or mutation(2%), with the remaining(8%) being copied as is. The 
# programs are written in the style of Lisp/Polish Notation, ie: 1 + 2 == (+ 1 2)
#
FUNCTIONS = [:+, :-, :*, :/]
TERMINALS = [:X, :R]

module Util
  class << self
    def generate_program(max,depth=0)
      if depth == max - 1 || (depth > 1 && rand() < 0.1)
        t = TERMINALS[rand(TERMINALS.length)]
        return ((t == :R) ? random_r_val(5) : t)
      end

      depth += 1
      arg1 = generate_program(max, depth)
      arg2 = generate_program(max, depth)

      return [FUNCTIONS[rand(FUNCTIONS.length)], arg1, arg2]
    end

    def copy_program(node)
      node.is_a?(Array) ? [node[0], copy_program(node[1]), copy_program(node[2])] : node
    end

    def random_r_val(n)
      (-n) + (((n)-(-n)) * rand())
    end

    def target_function(n)
      n**2 + n + 1
    end
  end
end

class Node
  attr_accessor :program, :fitness, :pop_size, :max_depth
  def initialize(pop_size, max_depth)
    @program   = []
    @fitness   = 0
    @pop_size  = pop_size
    @max_depth = max_depth
  end

  def eval_program(node, map)
    unless node.is_a?(Array)
      map[node].nil? ? (return node.to_f) : (return map[node].to_f)
    end

    first_node  = eval_program(node[1], map)
    second_node = eval_program(node[2], map)
    return 0 if node.first == :/ && second_node == 0.0
    first_node.send(node[0], second_node)
  end

  def set_fitness(num_trials=20)
    error = 0.0
    num_trials.times do |i|
      input  = Util.random_r_val(1)
      error += (eval_program(program, {:X => input}) - Util.target_function(input)).abs
    end

    @fitness = error.fdiv(num_trials.to_f)
  end
end

class Tree
  attr_accessor :pop_size, :max_depth, :nodes
  def initialize(pop_size, max_depth)
    @nodes     = []
    @pop_size  = pop_size
    @max_depth = max_depth
  end

  def populate
    @nodes = Array.new(pop_size) { Node.new(pop_size, max_depth) }
    @nodes.each { |n| n.program = Util.generate_program(max_depth) }
    @nodes.each { |n| n.set_fitness }
  end

  def prune(node, depth=0)
    if depth == max_depth-1
      term = TERMINALS[rand(TERMINALS.length)]
      return ((term == :R) ? Util.random_r_val(5) : term)
    end
    depth += 1
    return node unless node.is_a?(Array)
    
    node_array1 = prune(node[1], depth)
    node_array2 = prune(node[2], depth)
    [node[0], node_array1, node_array2]
  end

  def get_node(node, node_num, current_node=0)
    return node,(current_node+1) if current_node == node_num
    current_node += 1
    return nil, current_node unless node.is_a?(Array)
    node_array1, current_node = get_node(node[1], node_num, current_node)
    return node_array1, current_node  unless node_array1.nil?
    node_array2, current_node = get_node(node[2], node_num, current_node)
    return node_array2,  current_node unless node_array2.nil?
    return nil, current_node
  end

  def crossover(parent1, parent2)
    point1 = rand(count_nodes(parent1) - 2) + 1
    tree1  = get_node(parent1, point1).first

    point2 = rand(count_nodes(parent2) - 2) + 1
    tree2  = get_node(parent2, point2).first

    child1 = prune(replace_node(parent1, Util.copy_program(tree2), point1).first)
    child2 = prune(replace_node(parent2, Util.copy_program(tree1), point2).first)
    [child1, child2]
  end

  def count_nodes(node)
    node.is_a?(Array) ? (count_nodes(node[1]) + count_nodes(node[2]) + 1) : 1
  end

  def replace_node(node, new_node, node_num, current=0)
    return [new_node,(current+1)] if current == node_num
    current += 1
    return [node,current] unless node.is_a?(Array)
    node_array1, current = replace_node(node[1], new_node, node_num, current)
    node_array2, current = replace_node(node[2], new_node, node_num, current)
    [[node[0], node_array1, node_array2], current]
  end

  def mutation(parent)
    tree  = Util.generate_program(max_depth/2)
    point = rand(count_nodes(parent))
    child = replace_node(parent, tree, point).first
    prune(child)
  end
end

class Selection
  attr_accessor :max_gens, :max_depth, :pop_size, :bouts, :p_repro, :p_cross, :p_mut
  def initialize(args)
    @max_gens  = args[:max_gens]
    @max_depth = args[:max_depth]
    @pop_size  = args[:pop_size]
    @bouts     = args[:bouts]
    @p_repro   = args[:p_repro]
    @p_cross   = args[:p_cross]
    @p_mut     = args[:p_mut]
  end

  def run_generations
    pop = Tree.new(pop_size, max_depth)
    pop.populate
    best_node = pop.nodes.min_by(&:fitness)

    max_gens.times do |gen|
      children = []

      while children.length < pop_size
        child1     = Node.new(pop_size, max_depth)
        parent1    = tournament_selection(pop, bouts)
        genetic_op = rand()

        if genetic_op < p_repro
          child1.program = Util.copy_program(parent1.program)
        elsif genetic_op < (p_repro + p_cross)
          child2 = Node.new(pop_size, max_depth)
          parent2 = tournament_selection(pop, bouts)

          child1.program, child2.program = pop.crossover(parent1.program, parent2.program)
          children << child2
        elsif genetic_op < (p_repro + p_cross + p_mut)
          child1.program = pop.mutation(parent1.program)
        end

        children << child1 if children.length < pop_size
      end
      children.map(&:set_fitness)

      pop.nodes = children
      candidate = pop.nodes.min_by(&:fitness)
      best_node = candidate if candidate.fitness <= best_node.fitness
      
      best_node.fitness == 0 ? (break puts "Gen: #{gen} | Fitness: #{best_node.fitness}") : (puts "Gen: #{gen} | Fitness: #{best_node.fitness}")
    end

    puts "\nFinal: \n#{"*"*6}\nFitness: #{best_node.fitness}, #{print_program(best_node.program)}"
  end

  def tournament_selection(pop, bouts)
    Array.new(bouts) { pop.nodes[rand(pop.nodes.length)] }.min_by(&:fitness)
  end

  def print_program(node)
    node.is_a?(Array) ? "(#{node[0]} #{print_program(node[1])} #{print_program(node[2])})" : (return node)
  end
end

selection = Selection.new({max_gens: 100, max_depth: 7, pop_size: 100, bouts: 5, p_repro: 0.08, p_cross: 0.90, p_mut: 0.02})
selection.run_generations