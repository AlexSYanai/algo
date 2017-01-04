#include <vector>
#include <iostream>

#include "print_vec.h"

std::vector<int> selectionSort(std::vector<int> &ary, const int len) {
  for (int i = 0; i < len; ++i) {
    int min = i;
    
    for (int j = i + 1; j < len; ++j) {
      if (ary[j] < ary[min]) {
        min = j;
      }
    }

    if (i != min) {
      std::swap(ary[i],ary[min]);
    }
  }


  return ary;
}

int main() {
  std::vector<int> input = {3,2,1};
  std::vector<int> output = selectionSort(input,input.size());
  printVec(output);

  input = {1,1,1,1,1,1};
  output = selectionSort(input,input.size());
  printVec(output);

  input = {1,2,2,2,3,3,4,0,100,-1,1,10};
  output = selectionSort(input,input.size());
  printVec(output);

  input = {};
  output = selectionSort(input,input.size());
  printVec(output);

  return 0;
}
