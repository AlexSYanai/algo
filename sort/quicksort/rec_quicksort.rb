# require 'benchmark'
def rec_quicksort(ary)
   return ary unless ary.length > 1
   pivot = ary.pop
   split_vals = ary.group_by { |n| n < pivot }
   quicksort(split_vals[true]) + [pivot] + quicksort(split_vals[false])
end

# p "Rec Quick 28:"
# Benchmark.bm do |x|
#   x.report {
#     rec_quicksort([4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5])
#   }
# end

# p "Rec Quick 54:"
# Benchmark.bm do |x|
#   x.report {
#     rec_quicksort([4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5])
#   }
# end