defmodule Rand do
  def init do
    << a :: 32, b :: 32, c :: 32 >> = :crypto.strong_rand_bytes(12)
    :random.seed(a,b,c)
  end 

  def num do
    init
    :random.uniform
  end

  def char(list) do
    Enum.at(list, :random.uniform(length(list)) - 1)
  end
end

defmodule Log do
  def show(offspring,i) do
    IO.puts "Generation: #{i}, Offspring: #{offspring}"
  end

  def found([target|i]) do
    IO.puts "#{target} found in #{i} iterations"
  end
end

defmodule Evolution do
  def select(target) do
    chars = (?A..?Z) |> Enum.to_list() |> List.insert_at(0, 32)
    (1..String.length(target))
      |> Enum.map(fn _-> Rand.char(chars) end)
      |> mutate(String.to_char_list(target),0,[],chars)
      |> Log.found()
  end

  def mutate(parent,target,i,_,_)     when target == parent, do: [parent|i]
  def mutate(parent,target,i,_,chars) when target != parent do
    w = fitness(parent,target)
    prev = reproduce(target,parent,w,0,mu_rate(w),chars)
    if w < fitness(prev,target) do
      parent = prev
      Log.show(parent,i)
    end
    mutate(parent,target,i+1,prev,chars)
  end

  def reproduce(target,parent,_,_,rate,chars) do
    (1..100) 
      |> Enum.to_list() 
      |> Stream.map(fn _-> mutation(parent,rate,chars) end)
      |> List.insert_at(0, parent) 
      |> Enum.max_by(fn n -> fitness(n,target) end)
  end

  def fitness(t,r) do
    (0..length(t)-1) 
      |> Stream.map(fn n -> abs(Enum.at(t,n) - Enum.at(r,n)) end) 
      |> Enum.reduce(fn a,b -> a + b end)
      |> calc()
  end

  def mutation(p,r,chars) do
    (0..length(p)-1) 
      |> Stream.map(fn n -> Enum.at(p,n) end)
      |> Enum.map(fn n -> if Rand.num <= r, do: Rand.char(chars), else: n end)
  end

  def calc(sum),  do: 100 * :math.exp(sum/-10)
  def mu_rate(n), do: 1   - :math.exp(-(100-n)/400)
end

Evolution.select("THIS IS A TEST PHRASE")