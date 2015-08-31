module Selection
  class << self
    def random_char(chars)
      chars.sample 
    end

    def mutate(parent,rate,chars)
      parent.each_char.collect { |char| rand <= rate ? random_char(chars) : char }.join
    end

    def mutation_rate(candidate,target)
      1.0 - Math.exp( -(100.0 - Selection.w(candidate,target)).fdiv(400))
    end

    def w(candidate,target) # Calculates fitness using the P0 = e^-x Poisson relationship
      Math.exp(candidate.chars.zip(target.chars).inject(0) { |a,b| a + (b[0].ord - b[1].ord).abs }.fdiv(-10))*100
    end

    def avg_mutation_rate(rates)
      rates.inject(:+).fdiv(rates.length)
    end
  end
end

module GeneticOutput
  class << self
    def edit_sentence(target,starting)
      starting.length > target.length ? (return starting.split("").sample(target.length).join("")) : (return starting + ("-"*(target.length-starting.length)))
    end

    def log(iteration,rate,target,fitness,parent,last=nil)
      last.nil? ? (puts "%4d %.2f %5.1f %s" % [iteration,rate,fitness,parent]) : (puts "\nGeneration: %4d\nAverage Mutation Rate: %.2f\nFitness: %5.1f\n%s" % [iteration,rate,fitness,parent])
    end
  end
end

class WordMutation
  attr_accessor :first_gen,:last_gen,:gen_count,:rates
  attr_reader   :target,:num_copies,:search_chars
  def initialize(target,copies=100)
    @target       = target
    @num_copies   = copies
    @rates        = []
    @last_gen     = ""
    @gen_count    = 1
    @search_chars = [("A".."Z").to_a,("a".."z").to_a," "].flatten
  end

  def set_parent(starting=nil)
    starting.nil? ? @first_gen = search_chars.sample(target.length).join("") : @first_gen = GeneticOutput.edit_sentence(target,starting)
  end

  def run_mutations
    until first_gen == target
      rates << Selection.mutation_rate(first_gen,target)
      reset_generation(gen_count,rates.last) until last_gen == first_gen
      @first_gen = (1..num_copies).map { Selection.mutate(first_gen,rates.last,search_chars) }.push(first_gen).max_by { |n| Selection.w(n,target) }
      @gen_count += 1
    end
  end

  def reset_generation(iteration,rate)
    GeneticOutput.log(iteration,rate,target,Selection.w(first_gen,target),first_gen)
    @last_gen = first_gen
  end

  def final_output
    GeneticOutput.log(gen_count,Selection.avg_mutation_rate(rates),target,Selection.w(first_gen,target),first_gen,"last")
  end
end

sentence = WordMutation.new("This is a test phrase")
sentence.set_parent
sentence.run_mutations
sentence.final_output
