#include <iostream>
#include <vector>

void printVec(const std::vector<int> &vec)
{
  for (const auto &element : vec) {
    std::cout << element << ' ';
  }

  std::cout << std::endl;
}
