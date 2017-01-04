#include <vector>
#include <iostream>

#include "print_vec.h"

std::vector<int> selectionSort(std::vector<int> &ary) {
  return ary;
}

int main() {
  std::vector<int> input = {3,2,1};
  std::vector<int> output = selectionSort(input);
  printVec(output);

  return 0;
}
