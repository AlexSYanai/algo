# My Ruby implementation of a basic genetic algorithm
# Based upon:
# Introduction to Genetic Algorithms Chapter 1
# Author: Melanie Mitchell
module NaturalEnvironment
  class << self
    def encapsulate_conditions(args)
      @population_n   = args[:n]   # Total experimental population
      @total_bits     = args[:l]   # Number of coding regions on chromosome
      @generations    = args[:gen] # Generations => # times algorithm runs
      @crossover_rate = args[:pc]  # Chance of chromosomes swap region of bits
      @mutation_rate  = args[:u]   # Chance a given locus switches bits
    end

    # Methods to access the condition variables
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
    def recombine(x,y) # Generates new child genomes in the event of crossover
      child_1, child_2 = get_regions(y,x,(rand(y.genes.length) + 1)), get_regions(x,y,(rand(y.genes.length) + 1))
      [Chromosome.new(child_1),Chromosome.new(child_2)]
    end

    def get_regions(genome_1,genome_2,locus) # Takes two xsome ranges and swaps them between the two parents
      genome_1.genes[0, locus] + genome_2.genes[locus, genome_2.genes.length]
    end
  end
end

class Chromosome # Genome and chromosome are used interchangeably due to the nature of the algorithm
  attr_accessor :genes
  def initialize(genes="") # If the genes aren't generated or initialized, randomly create a new xsome
    genes == "" ? self.genes = (1..NaturalEnvironment.num_bits).map { rand(2) }.join : self.genes = genes
  end

  def count
    self.genes.length
  end

  def w               # W denotes fitness in population genetics
    genes.count("1")  # Assuming here that a coding region(bit) w/a value 1  increases fitness
  end                 # By extension 0 are neutral so technically, wrt mutations, slightly deleterious

  def mutate # Randomly mutate genes, changing an individual allele to 1 if it is currently 0
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

  def inspect_chromosome # Accesses all the genes of all the xsomes in a given population
    chromosomes.map(&:genes)
  end

  def populate # Populates the population with individuals, represented by xsomes
    self.chromosomes = Array.new(NaturalEnvironment.num_pop) { Chromosome.new }
  end

  def count
    chromosomes.length
  end

  def fitness_values # Accesses the fitness values for each xsome
    chromosomes.map(&:w)
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

  def select   # Return the selected chromosome from a given population (called twice)
    total = 0
    random_selection = rand(w_total) # Randomly select a value within pop's total fitness
    chromosomes.each_with_index do |xsome, index| # For each xsome in the population
      total += xsome.w                             # Keep a running total of the fitness of each
      (return xsome) if total > random_selection || index == (chromosomes.length - 1)
    end # Return an xsome if the total is above the fitness value or it is the last xsome in the population
  end
end

class Selection
  attr_accessor :prev_gen
  def initialize(args) # Wrap test conditions
    NaturalEnvironment.encapsulate_conditions(args)
  end

  def new_generation_zero # Seed the first generation
    @prev_gen = Population.new
    prev_gen.populate
  end

  def run_generations # Run the test conditions num_gens times
    NaturalEnvironment.num_gens.times do |generation|
      offspring = Population.new # Initialize the new offspring population

      while offspring.count < prev_gen.count # Creates the new generation
        parent_1, parent_2 = select_chromosomes
        child_1, child_2 = analyze_crossover(parent_1,parent_2)
        mutate_chromosomes(child_1,child_2)
        add_offspring(offspring,child_1,child_2)
      end

      # Comment out or remove this method to not display the stats of all generation
      display_selection(generation,prev_gen.w_average.round(2),prev_gen.w_max)
      @prev_gen = offspring # Child generation becomes the new parent generation
    end
  end

  def select_chromosomes
    [prev_gen,prev_gen].map(&:select)
  end

  def analyze_crossover(fn1,fn2) # Randomly chooses whether to recombine parent xsomes
    rand <= NaturalEnvironment.crossover ? Nucleus.recombine(fn1,fn2) : [fn1,fn2]
  end

  def mutate_chromosomes(child_1,child_2)
    [child_1, child_2].map(&:mutate)
  end

  def add_offspring(offspring,child_1,child_2) # Add children: Either both or one, depending upon the test population size
    NaturalEnvironment.num_pop.even? ? offspring.chromosomes.push(child_1,child_2) : offspring.chromosomes.push([child_1, child_2].sample)
  end

  def display_selection(generation,current_w,max_current_w)
    puts "Gen: #{generation} | Avg: #{current_w} | Max: #{max_current_w}"
  end

  def display_stats
    puts ["Generation #{NaturalEnvironment.num_gens}", "Avgerage Fitness: #{prev_gen.w_average.round(2)}", "Max Fitness: #{prev_gen.w_max}"]
  end

  def display_final_xsomes # Formats and displays final xsome bit-strings
    prev_gen.inspect_chromosome.each_with_index { |xsome,i| (i+1) < 10 ? (puts "N#{i+1}:  #{xsome}") : (puts "N#{i+1}: #{xsome}") }
  end
end

drosophila = Selection.new({n: 32, l: 64, gen: 1000, pc: 0.8, u: 0.004})
drosophila.new_generation_zero
drosophila.run_generations
drosophila.display_stats
drosophila.display_final_xsomes
