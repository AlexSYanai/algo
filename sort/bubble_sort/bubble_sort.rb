require 'benchmark'

def bubble_sort(array)
  n = array.length
  loop do
    swapped = false
    (n-1).times { |i| array[i], array[i+1], swapped = array[i+1], array[i], true if array[i] > array[i+1] } 
    break unless swapped
  end
  array
end

p bubble_sort([4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5])

p "Classic Benchmark 28:"
Benchmark.bm do |x|
  x.report {
    bubble_sort([4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5])
  }
end

p "Classic Benchmark 54:"
Benchmark.bm do |x|
  x.report {
    bubble_sort([4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5])
  }
end