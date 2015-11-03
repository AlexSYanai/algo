var knapsack = function() {
  function genMatrix(maxWeight,lenItems) {
    itemMatrix = [];
    for (i = 0; i < lenItems; i++) {
      temp = [];
      for (j = 0; j < maxWeight; j++) {
        temp[j] = 0;
      }
      itemMatrix.push(temp);
    }

    return itemMatrix;
  }

  function compareItems(itemList, maxWeight, lenItems) {
    var matrix = genMatrix(maxWeight, lenItems);

    for (x = 0; x < lenItems; x++) {
      for (y = 0; y < maxWeight; y++) {
        var x_v = x - 1;
        var i_w = y - itemList[x].weight;
        
        if (x === 0) {
          x_v = lenItems - 1;
        } else if (y < 0) {
          i_w = maxWeight + lenItems;
        }

        if (itemList[x].weight > y) {
          matrix[x][y] = matrix[x_v][y];
        } else {
          if (matrix[x_v][y] > (itemList[x].val + matrix[x_v][i_w])) {
            matrix[x][y] = matrix[x_v][y];
          } else {
            matrix[x][y] = (itemList[x].val + matrix[x_v][i_w]);
          }
        }
      }
    }

    return matrix;
  }

  function selectBest(itemList, matrix) {
    var currentTotal  = matrix[0].length - 1;
    var selectedItems = [];

    for (i = 0; i < itemList.length; i++) {
      selectedItems.push(0);
    }
    
    for (i = matrix.length - 1; i >= 0; i--) {
      if (currentTotal < 0) {
        break;
      } else {
        if ((i == 0 && matrix[i][currentTotal] > 0) || (matrix[i][currentTotal] != matrix[i-1][currentTotal])) {
          selectedItems[i] = 1;
          currentTotal    -= itemList[i].weight;
        }
      }
    }

    return selectedItems;
  }

  function printValues(items, selected) {
    var weightSum = 0;
    var valueSum  = 0;

    for (i = 0; i < items.length; i++) {
      if (selected[i] == 1) {
        console.log(items[i].name);
        weightSum += items[i].weight;
        valueSum  += items[i].val;
      }
    }

    console.log("\nFinal Weight: " + weightSum);
    console.log("Final Value:  "   + valueSum);
  }

  return {
    init: function(items, maxWeight) {
      var items      = items;
      var maxWeight  = maxWeight;
      var itemMatrix = compareItems(items, maxWeight, items.length - 1);
      var selected   = selectBest(items, itemMatrix);

      printValues(items, selected);
    }
  };
}();

var items = [
  { name: 'map',      weight: 9,   val: 150 },
  { name: 'compass',  weight: 13,  val:  35 },
  { name: 'water',    weight: 153, val: 200 },
  { name: 'snackbar', weight: 50,  val: 160 },
  { name: 'canteen',  weight: 15,  val:  60 },
  { name: 'cookware', weight: 68,  val:  45 },
  { name: 'banana',   weight: 27,  val:  60 },
  { name: 'apple',    weight: 39,  val:  40 },
  { name: 'snacks',   weight: 23,  val:  30 },
  { name: 'soda',     weight: 52,  val:  10 },
  { name: 'lotion',   weight: 11,  val:  70 },
  { name: 'camera',   weight: 32,  val:  30 },
  { name: 'shirt',    weight: 24,  val:  15 },
  { name: 'pants',    weight: 48,  val:  10 },
  { name: 'umbrella', weight: 73,  val:  40 },
  { name: 'pants',    weight: 42,  val:  70 },
  { name: 'coat',     weight: 43,  val:  75 },
  { name: 'notebook', weight: 22,  val:  80 },
  { name: 'glasses',  weight: 7,   val:  20 },
  { name: 'towel',    weight: 18,  val:  12 },
  { name: 'socks',    weight: 4,   val:  50 },
  { name: 'book',     weight: 30,  val:  10 }
];

knapsack.init(items, 400);
