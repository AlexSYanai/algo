# My Ruby implementation of a basic genetic algorithm
# Based upon:
# Introduction to Genetic Algorithms Chapter 1
# Author: Melanie Mitchell

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
			child_1, child_2 = get_region(y,x,(rand(y.genes.length) + 1)), get_region(x,y,(rand(y.genes.length) + 1))
			[Chromosome.new(child_1),Chromosome.new(child_2)]
		end

		def get_region(genome_1,genome_2,locus)
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
		genes.length
	end

	def w 							# W denotes fitness in population genetics
		genes.count("1")  # Assuming here that a coding region(bit) w/a value 1  increases fitness
	end

	def mutate
		mutated = ""
		0.upto(genes.length - 1) do |i|
			allele = genes[i, 1]
			if rand <= NaturalEnvironment.rate_mute
				(allele == "0") ? mutated << "1" : mutated << "0"
			else
				mutated << allele
			end
		end
		self.genes = mutated
	end
end

class Population
	attr_accessor :chromosomes
	def initialize
		self.chromosomes = []
	end

	def inspect
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
		random_selection = rand(w_total)
		total = 0
		chromosomes.each_with_index do |chromosome, index|
			total += chromosome.w
			(return chromosome) if total > random_selection || index == (chromosomes.count - 1)
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
				child_1, child_2 = mutate_chromosomes(parent_1,parent_2)
				[child_1, child_2].map(&:mutate)

				if NaturalEnvironment.num_pop.even?
					offspring.chromosomes << child_1 << child_2
				else
					offspring.chromosomes << [child_1, child_2].sample
				end
			end

			# display_selection(generation,prev_gen.w_average.round(2),prev_gen.w_max)
			@prev_gen = offspring
		end
	end

	def select_chromosomes
		[prev_gen,prev_gen].map(&:select)
	end

	def mutate_chromosomes(fn1,fn2)
		rand <= NaturalEnvironment.crossover ? Nucleus.recombine(fn1,fn2) : [fn1,fn2]
	end

	def display_selection(generation,current_w,max_current_w)
		puts "Gen #{generation} - Avg: #{current_w} - Max: #{max_current_w}"
	end

	def display_stats
		puts ["Generation #{NaturalEnvironment.num_gens}", "Avgerage Fitness: #{prev_gen.w_average.round(2)}", "Max Fitness: #{prev_gen.w_max}"]
	end

	def display_final_genome
		prev_gen.inspect.each_with_index { |xsome,i| (i+1) < 10 ? (puts "N#{i+1}:  #{xsome}") : (puts "N#{i+1}: #{xsome}")}
	end
end

drosophila = Selection.new({n: 24, l: 64, gen: 1000, pc: 0.7, u: 0.001})
drosophila.new_generation_zero
drosophila.run_generations
drosophila.display_stats
drosophila.display_final_genome











