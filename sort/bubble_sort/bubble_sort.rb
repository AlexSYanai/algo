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

p "---------------------------"

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

p "---------------------------"

def in_place_bitwise_bubble(arr)
  n = arr.size - 1
  k = 1
  loop do                       # Keep looping until sorting is finished
    swapped = false             # Set swapped status to false
    0.upto(n-k) do |i|          # Repeatedly start from beginning and lower the end bound 
      if arr[i] > arr[i+1]      # If the first is greater than the second, swap by X Or - ex:
        xor = arr[i]^arr[i+1]   # 4^3 => 11^10 => 01 => 1
        arr[i] = xor^arr[i]     # 1^4 => 01^11 => 10 => 3 
        arr[i+1] = xor^arr[i+1] # 1^3 => 01^10 => 11 => 4 
        swapped = true          
      end
    end
    break unless swapped        # Break the loop when no swap takes place in an iteration
    k +=1                       # Lowers the outer bound, since each loop should leave a  
  end                           # high val at the end
  arr
end

p "Bitwise Benchmark 28:"
Benchmark.bm do |x|
  x.report {
    in_place_bitwise_bubble([4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5])
  }
end

p "Bitwise Benchmark 54:"
Benchmark.bm do |x|
  x.report {
    in_place_bitwise_bubble([4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5])
  }
end

