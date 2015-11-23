defmodule Rand do
  def init do
    << a :: 32, b :: 32, c :: 32 >> = :crypto.strong_rand_bytes(12)
    :random.seed(a,b,c)
  end 

  def num do
    init
    :random.uniform
  end

  def ten_num(len) do
    round(num * len)
  end
end

defmodule World do
  def conditions(init_conditions) do
    Enum.into(init_conditions, Map.new)
  end
end

defmodule Chromosome do
  def w(genes) do
    Regex.scan(~r/1/, genes) |> length()
  end

  def new_base do
    if Rand.num > 0.5, do: "0", else: "1" 
  end

  def set_genes(enviro) do
    1..enviro.num_bits |> Enum.map(fn _ -> new_base end) |> Enum.join()
  end

  def mutate(mutated,gene,enviro,i,len) when i > len, do: mutated
  def mutate(mutated,gene,enviro,i,len) when i <= len do
    if String.at(gene,i) == "0" do
      mutated = "0" <> mutated
    else
      if Rand.num <= enviro.mRate, do: mutated = "0" <> mutated, else: mutated = "1" <> mutated
    end

    mutate(mutated,gene,enviro,i + 1,len)
  end

  def select([xsome|xsomes],  total, rand_select) when total >= rand_select, do: xsome
  def select([xsome|_xsomes], total, rand_select), do: xsome
  def select([xsome|xsomes],  total, rand_select) when total < rand_select do
    select(xsomes,total + Chromosome.w(xsome), rand_select)
  end
end

defmodule Nucleus do
  def recombine(xsome1, xsome2, locus) do
    {child1, child2} = xsome1 |> String.split_at(locus)
    {child3, child4} = xsome2 |> String.split_at(locus)
    child1 <> child4
  end

  def set_xover(xsome1, xsome2) do
    child1 = recombine(xsome1, xsome2, Rand.ten_num(String.length(xsome1)))
    child2 = recombine(xsome2, xsome1, Rand.ten_num(String.length(xsome2)))

    {child1, child2}
  end
end

defmodule Population do
  def populate(pop, i, enviro) when length(pop) >= 32, do: pop
  def populate(pop, i, enviro) when length(pop) <  32  do
    populate(pop ++ [Chromosome.set_genes(enviro)], i + 1, enviro)
  end

  def w([], w_total, w_max, enviro), do: {w_total, w_max}
  def w([xsome|xsomes], w_total, w_max, enviro) do
    fitness = Chromosome.w(xsome)
    if fitness >= w_max, do: w_max = fitness
    w(xsomes, w_total + fitness, w_max, enviro)
  end
end

defmodule Selection do
  def init(enviro) do
    first = Population.populate([], 0, enviro)
    run_generations(first, 0, enviro)
  end

  def run_generations(prev_gen, i, enviro) when i >= 1000 do
    {w_total, w_max} = Population.w(prev_gen, 0, 0, enviro)
    IO.puts "Gen: #{i} | Avg: #{w_total/length(prev_gen)} | Max: #{w_max}"
  end

  def run_generations(prev_gen, i, enviro) when i < 1000 do
    {gen, w_max, w_avg} = calculate_generations(prev_gen, [], enviro)
    IO.puts "Gen: #{i} | Avg: #{w_avg} | Max: #{w_max}"
    run_generations(gen, i + 1, enviro)
  end

  def calculate_generations(prev_gen, offspring, enviro) when length(offspring) >= length(prev_gen) do
    {w_total, w_max} = Population.w(offspring, 0, 0, enviro)
    {offspring, w_max, (w_total/length(offspring))}
  end

  def calculate_generations(prev_gen, offspring, enviro) when length(offspring) < length(prev_gen) do
    {wt, wm} = Population.w(prev_gen, 0, 0, enviro)

    parent1  = Chromosome.select(prev_gen, 0, Rand.ten_num(wt))
    parent2  = Chromosome.select(prev_gen, 0, Rand.ten_num(wt))
    
    {child1, child2} = analyze_crossover(parent1, parent2, enviro)

    child1 = Chromosome.mutate("", child1, enviro, 0, String.length(child1))
    child2 = Chromosome.mutate("", child2, enviro, 0, String.length(child2))

    calculate_generations(prev_gen, [child1, child2] ++ offspring, enviro)
  end

  def analyze_crossover(parent1, parent2, enviro) do
    if Rand.num <= enviro do
      {child1, child2} = Nucleus.set_xover(parent1,parent2)
    else
      {child1, child2} = {parent1, parent2}
    end
    {child1, child2}
  end
end


init_conditions = [n: 32, num_bits: 64, gens: 1000, xoverRate: 0.8, mRate: 0.04]
enviro = World.conditions(init_conditions)
Selection.init(enviro)
