defmodule FibAgent do 
  def start_link do
    cache = Enum.into([{0, 0}, {1, 1}], HashDict.new)
    Agent.start_link(fn -> cache end)
  end
 
  def fib(pid, n) when n >= 0 do
    Agent.get_and_update(pid, &do_fib(&1, n))
  end
 
  defp do_fib(cache, n) do
    if cached = cache[n] do
      IO.inspect cache
      {cached, cache}
    else
      {val, cache} = do_fib(cache, n - 1)
      result = val + cache[n-2]
      IO.inspect cache
      {result, Dict.put(cache, n, result)}
    end
  end
end

{:ok, agent} = FibAgent.start_link()
IO.puts FibAgent.fib(agent, 20)