require 'benchmark'

def rec_bubble_sort(to_sort)
  arr_to_sort = to_sort.dup
  swapped = false
  (arr_to_sort.length - 1).times.each do |i|
    if arr_to_sort[i] > arr_to_sort[i+1]
      x = arr_to_sort[i]
      arr_to_sort.delete_at(i)
      arr_to_sort.insert(i+1,x)
      swapped = true
    end
  end
  swapped == false ? (return arr_to_sort) : rec_bubble_sort(arr_to_sort)
end

p rec_bubble_sort([4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5])

p "Rec Benchmark 28:"
Benchmark.bm do |x|
  x.report {
    rec_bubble_sort([4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5])
  }
end

p "Rec Benchmark 54:"
Benchmark.bm do |x|
  x.report {
    rec_bubble_sort([4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5])
  }
end