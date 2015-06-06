# require 'benchmark'

def rec_bin_search(target,array,low=0,high=array.length-1)
  middle = (high + low) / 2
	return -1 if low > high
	target <  array[middle] ? high = (middle - 1) : low = (middle + 1)
	target == array[middle] ? (return middle) : rec_bin_search(target,array,low,high)
end

# p "Recursive Binary Search 2:"
# Benchmark.bm do |x|
#   x.report {
#     rec_bin_search(32, [32,13])
#   }
# end

# p "Recursive Binary Search 7:"
# Benchmark.bm do |x|
#   x.report {
#     rec_bin_search(32, [13, 19, 24, 29, 32, 37, 43])
#   }
# end

# p "Recursive Binary Search: 300"
# Benchmark.bm do |x|
#   x.report {
#     rec_bin_search(32, (1..300).to_a)
#   }
# end