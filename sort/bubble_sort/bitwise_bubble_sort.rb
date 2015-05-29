require 'benchmark'

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

p in_place_bitwise_bubble([4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5])

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