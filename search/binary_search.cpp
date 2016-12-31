#include <vector>
#include <iostream>

static int binarySearch(int target, std::vector<int> ary, int low, int high)
{
  int middle = (high + low)/2;

  if (low > high)
    return -1;

  (target < ary[middle]) ? high = middle - 1 : low = middle + 1;

  if (target == ary[middle])
  {
    return middle;
  } else {
    return binarySearch(target,ary,low,high);
  }
}

static void binarySearchTest()
{
  bool found;
  std::vector<int> ary = { 1, 2, 4, 7, 9, 11, 13, 14, 15, 17, 19, 22, 24, 27, 30 };

  std::cout << std::boolalpha;

  found = binarySearch(11,ary,0,ary.size()) == 5;
  std::cout << found << std::endl;

  found = binarySearch(1,ary,0,ary.size()) == 0;
  std::cout << found << std::endl;

  found = binarySearch(30,ary,0,ary.size()) == 14;
  std::cout << found << std::endl;

  found = binarySearch(99,ary,0,ary.size()) == -1;
  std::cout << found << std::endl;
}

int main()
{
  std::vector<int> ary = { 1, 2, 4, 7, 9, 11, 13, 14, 15, 17, 19, 22, 24, 27, 30 };

  int bin = binarySearch(30,ary,0,ary.size());
  std::cout << bin << std::endl;
  
  binarySearchTest();  
  return 0;
}
