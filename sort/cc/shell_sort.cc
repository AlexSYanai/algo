#include <vector>
#include <iostream>

#include "print_vec.h"

int GenerateStartVal(const int third_len) {
  int h = 1;

  //For h-sorting => 3x + 1 => 1, 4, 13, 40, 121 etc.
  while (h < third_len) {
    h = (3 * h) + 1;
  }
  
  return h;
}

// Using Insertion Sort code w/minor modifications to decrement by h instead of 1
void InsertionSort(std::vector<int> &ary, const int len, const int h) {
  for (int i = h; i < len; ++i) {
    for (int j = i; j >= h && ary[j] < ary[j - h]; j -= h) {
      std::swap(ary[j],ary[j - h]);
    }
  }
}

// Generate a a value, h, then sorts h interleaved subsequences
std::vector<int> ShellSort(std::vector<int> &ary, const int len) {
  int h = GenerateStartVal(len/3);

  while (h >= 1) {
    InsertionSort(ary,len,h);
    h /= 3;
  }

  return ary;
}

int main() {
  std::vector<int> input = {3,2,1};
  std::vector<int> output = ShellSort(input,input.size());
  printVec(output);

  input = {1,1,1,1,1,1};
  output = ShellSort(input,input.size());
  printVec(output);

  input = {1,2,2,2,3,3,4,0,100,-1,1,10,13,99,-1000,1,7};
  output = ShellSort(input,input.size());
  printVec(output);

  input = {};
  output = ShellSort(input,input.size());
  printVec(output);

  return 0;
}
