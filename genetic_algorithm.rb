# # My Ruby implementation of a basic genetic algorithm
# # Based upon:
# # Introduction to Genetic Algorithms Chapter 1
# # Author: Melanie Mitchell
require 'pry'
module NaturalEnvironment
	class << self
		def encapsulate_conditions(args)
			@population_n   = args[:n]
			@total_bits     = args[:l]   # Number of coding regions on chromosome
			@generations    = args[:gen] # Generations => # times algorithm runs
			@crossover_rate = args[:pc]  # Chance of chromosomes swap region of bits
			@mutation_rate  = args[:u]   # Chance a given locus switches bits
		end

		def num_pop
			@population_n
		end

		def num_bits
			@total_bits
		end

		def num_gens
			@generations
		end

		def crossover
			@crossover_rate
		end

		def rate_mute
			@mutation_rate
		end
	end
end

module Nucleus
	class << self
		def recombine(x,y)
			child_1, child_2 = get_regions(y,x,(rand(y.genes.length) + 1)), get_regions(x,y,(rand(y.genes.length) + 1))
			[Chromosome.new(child_1),Chromosome.new(child_2)]
		end

		def get_regions(genome_1,genome_2,locus)
			genome_1.genes[0, locus] + genome_2.genes[locus, genome_2.genes.length]
		end
	end
end

class Chromosome
	attr_accessor :genes
	def initialize(genes="")
		genes == "" ? self.genes = (1..NaturalEnvironment.num_bits).map { rand(2) }.join : self.genes = genes
	end

	def count
		self.genes.length
	end
 
	def w 							# W denotes fitness in population genetics
		genes.count("1")  # Assuming here that a coding region(bit) w/a value 1  increases fitness
	end

	def mutate
		self.genes.chars.each_with_index do |allele,i|
			allele == "0" ? self.genes[i] = "1" : self.genes[i] = "0" if rand <= NaturalEnvironment.rate_mute
		end
	end
end

class Population
	attr_accessor :chromosomes
	def initialize
		self.chromosomes = []
	end

	def inspect_chromosome
		chromosomes.map(&:genes)
	end

	def populate
		self.chromosomes = Array.new(NaturalEnvironment.num_pop) { Chromosome.new }
	end

	def count
		chromosomes.length
	end

	def fitness_values
		chromosomes.collect(&:w)
	end

	def w_total
		fitness_values.inject(:+)
	end

	def w_max
		fitness_values.max
	end

	def w_average
		w_total.fdiv(chromosomes.length)
	end

	def select
		total = 0
		random_selection = rand(w_total)
		chromosomes.each_with_index do |xsome, index|
			total += xsome.w
			(return xsome) if total > random_selection || index == (chromosomes.count - 1)
		end
	end
end

class Selection
	attr_accessor :prev_gen
	def initialize(args)
		NaturalEnvironment.encapsulate_conditions(args)
	end

	def new_generation_zero
		@prev_gen = Population.new
		prev_gen.populate
	end

	def run_generations
		NaturalEnvironment.num_gens.times do |generation|
			offspring = Population.new

			while offspring.count < prev_gen.count
				parent_1, parent_2 = select_chromosomes				 
				child_1, child_2 = analyze_crossover(parent_1,parent_2)
				mutate_chromosomes(child_1,child_2)
				add_offspring(offspring,child_1,child_2)
			end

			display_selection(generation,prev_gen.w_average.round(2),prev_gen.w_max)
			@prev_gen = offspring
		end
	end

	def select_chromosomes
		[prev_gen,prev_gen].map(&:select)
	end

	def analyze_crossover(fn1,fn2)
		rand <= NaturalEnvironment.crossover ? Nucleus.recombine(fn1,fn2) : [fn1,fn2]
	end

	def mutate_chromosomes(child_1,child_2)
		[child_1, child_2].map(&:mutate)
	end

	def add_offspring(offspring,child_1,child_2)
		NaturalEnvironment.num_pop.even? ? offspring.chromosomes.push(child_1,child_2) : offspring.chromosomes.push([child_1, child_2].sample)
	end

	def display_selection(generation,current_w,max_current_w)
		puts "Gen #{generation} - Avg: #{current_w} - Max: #{max_current_w}"
	end

	def display_stats
		puts ["Generation #{NaturalEnvironment.num_gens}", "Avgerage Fitness: #{prev_gen.w_average.round(2)}", "Max Fitness: #{prev_gen.w_max}"]
	end

	def display_final_genome
		prev_gen.inspect_chromosome.each_with_index { |xsome,i| (i+1) < 10 ? (puts "N#{i+1}:  #{xsome}") : (puts "N#{i+1}: #{xsome}") }
	end
end

drosophila = Selection.new({n: 32, l: 64, gen: 1000, pc: 0.8, u: 0.004})
drosophila.new_generation_zero
drosophila.run_generations
drosophila.display_stats
drosophila.display_final_genome