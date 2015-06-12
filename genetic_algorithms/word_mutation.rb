module Selection
  class << self
    def random_char(r_chars)
      r_chars.sample 
    end

    def mutate(parent,rate,r_chars)
      parent.each_char.collect { |char| rand <= rate ? random_char(r_chars) : char }.join
    end

    def mutation_rate(candidate,target)
      1.0 - Math.exp( -(100.0 - Selection.w(candidate,target)).fdiv(400))
    end

    def w(candidate,target) # Calculates fitness using the P0 = e^-x Poisson relationship
      Math.exp(candidate.chars.zip(target.chars).inject(0) { |a,b| a + (b[0].ord - b[1].ord).abs }.fdiv(-10))*100
    end
  end
end

module GeneticOutput
  class << self
    def edit_sentence(target_length,starting)
      starting.length > target_length ? (return starting[0..target_length]) : (return starting + ("-"*(target_length-starting.length)))
    end

    def log(iteration,rate,target,parent,last=nil)
      last.nil? ? (puts "%4d %.2f %5.1f %s" % [iteration,rate,Selection.w(parent,target),parent]) : (puts "Generation: %4d\nMutation Rate: %.2f\nFitness: %5.1f\n%s" % [iteration,rate,Selection.w(parent,target),parent])
    end
  end
end

class WordMutation
  attr_accessor :first_gen
  attr_reader   :target,:num_copies,:search_chars
  def initialize(target)
    @target       = target
    @num_copies   = 100
    @search_chars = [("A".."Z").to_a,("a".."z").to_a," "].flatten
  end

  def set_parent(starting=nil)
    starting.nil? ? @first_gen = search_chars.sample(target.length).join("") : @first_gen = GeneticOutput.edit_sentence(target.length,starting)
  end

  def run_mutations
    prev = ""
    iteration = 0
    until first_gen == target
      iteration += 1
      rate = Selection.mutation_rate(first_gen,target)
      until prev == first_gen
        GeneticOutput.log(iteration,rate,target,first_gen)
        prev = first_gen
      end
      copies = [first_gen] + Array.new(num_copies) {Selection.mutate(first_gen, rate, search_chars)}
      @first_gen = copies.max_by { |c| Selection.w(c,target) }
    end
    GeneticOutput.log(iteration,rate,target,first_gen,"last")
  end
end

sentence = WordMutation.new("METHINKS IT IS LIKE A WEASEL")
sentence.set_parent
sentence.run_mutations
