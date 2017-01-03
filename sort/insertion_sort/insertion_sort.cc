#include <vector>
#include <iostream>

void printVec(const std::vector<int> &vec)
{
  for (const auto &element : vec) {
    std::cout << element << ' ';
  }

  std::cout << std::endl;
}

std::vector<int> insertionSort(std::vector<int> &ary, const int len) {
  for (int i = 1; i < len; i++) {
    for (int j = i; j > 0 && ary[j] < ary[j - 1]; j--) {
      std::swap(ary[j], ary[j-1]);
    }
  }

  return ary;
}

int main() {
  std::vector<int> input = {3,2,1};
  std::vector<int> output = insertionSort(input,input.size());
  printVec(output);

  input  = {1,1,1,1,1};
  output = insertionSort(input,input.size());
  printVec(output);

  input  = {1,2,2,2,3,3,4,0,100,-1,1,10};
  output = insertionSort(input,input.size());
  printVec(output);

  input  = {};
  output = insertionSort(input,input.size());
  printVec(output);

  return 0;
}
