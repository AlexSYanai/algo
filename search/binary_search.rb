# require 'benchmark'

def bin_search(target,array)
  return -1 if target.nil?
  low = 0
  high = array.length - 1
  until high < low
    mid = (high + low) / 2
    array[mid] > target ? high = mid - 1 : (array[mid] < target ? low = mid + 1 : (return mid))
  end
  
  -1
end

# p "Recursive Binary Search 2:"
# Benchmark.bm do |x|
#   x.report {
#     bin_search(32, [32,13])
#   }
# end

# p "Recursive Binary Search 7:"
# Benchmark.bm do |x|
#   x.report {
#     bin_search(32, [13, 19, 24, 29, 32, 37, 43])
#   }
# end

# p "Recursive Binary Search: 300"
# Benchmark.bm do |x|
#   x.report {
#     bin_search(32, (1..300).to_a)
#   }
# end
