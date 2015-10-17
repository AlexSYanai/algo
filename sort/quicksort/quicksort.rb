# require 'benchmark'
def quicksort(array)
  bottom, top = [array.length], [0]
  i = 0
  until i < 0
    left = top[i]
    right = (bottom[i] - 1)
    if left < right
      pivot = array[left]
      while left < right
        right -= 1 while (array[right] >= pivot && left < right)
        if (left < right)
          array[left] = array[right]
          left += 1
        end
        left += 1 while (array[left] <= pivot && left < right)
        if (left < right)
          array[right] = array[left]
          right -= 1
        end
      end
      array[left] = pivot
      top[i+1] = (left + 1)
      bottom[i+1] = bottom[i]
      bottom[i] = left
      i += 1
    else
      i -= 1
    end
  end
  array
end


# p "Quicksort 28:"
# Benchmark.bm do |x|
#   x.report {
#     quicksort([4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5])
#   }
# end

# p "Quicksort 54:"
# Benchmark.bm do |x|
#   x.report {
#     quicksort([4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5,4,3,5,3,1,324,5])
#   }
# end
