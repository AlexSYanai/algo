# Based on a CodeEval challenge
# Starting from the uppper left corner of a
# 4X4 grid,find how many paths can be taken
# to reach the bottom right corner, assuming
# that tiles can only be traversed once per
# path.
def count_paths(matrix,x,y)
  return 0 if matrix[x][y]
  return 1 if x == 3 && y == 3
  i = 0
  matrix[x][y] = true
  i += count_paths(matrix,(x - 1),y) if x > 0
  i += count_paths(matrix,(x + 1),y) if x < 3
  i += count_paths(matrix,x,(y - 1)) if y > 0
  i += count_paths(matrix,x,(y + 1)) if y < 3
  matrix[x][y] = nil
  i
end

matrix = Array.new(4) { Array.new(4) {nil} }
puts count_paths(matrix,0,0)
