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
  for (int i = 1; i < len; ++i) {
    int key = ary[i];

    int j;
    for (j = i -  1; j >= 0 && ary[j] > key; j--) {
      ary[j + 1] = ary[j]; 
    }

    ary[j + 1] = key;                              
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

  input  = {};
  output = insertionSort(input,input.size());
  printVec(output);

  return 0;
}
