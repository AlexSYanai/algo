# Parses the items and creates the individual Items
module ItemFactory
  Item = Struct.new(:name,:weight,:value)
  @item_list = []
  class << self
    def create_list(items)    # Accepts an Array and create a list of items if multiple are given, either a Hash or an Array
      items.each { |item| item.is_a?(Hash) ? @item_list <<  Item.new(item[:name],item[:weight],item[:value]) : @item_list << Item.new(item[0],item[1],item[2]) }
    end

    def add_single_item(item) # Accepts an Array and creates a single item, in either a Hash or an Array
      item.is_a?(Hash) ? @item_list << Item.new(item[:name],item[:weight],item[:value]) : @item_list << Item.new(item[0],item[1],item[2])
    end

    def list                  # Accesses the already chosen item => more items can be added later for a new output
      @item_list
    end

    def clear_item_list       # Clears the item list for the creation of a new knapsack
      @item_list = []
    end
  end
end

class BackPacker
  attr_accessor :item_list,:utility_matrix,:selected
  attr_reader   :max_weight,:knapsack,:items
  def initialize(items,max_weight)
    @items          = items
    @max_weight     = max_weight
    @utility_matrix = Array.new(items.length) { Array.new(max_weight+1) {0} }
  end

  def get_items(*new_items) # Generates list for initialized items or add new items
    @items ||= new_items
    items.length == 1 ? ItemFactory.add_single_item(items) : ItemFactory.create_list(items)
    @item_list = ItemFactory.list
  end

  def get_knapsack_vals # Methods that actually calculate the relative utilities of each item
    compare_item_utility
    find_selected_items
  end

  def select_appropriate_knapsack # Creates the new knapsack
    @knapsack = Knapsack.new(item_list,selected,utility_matrix)
  end

  def clear_item_list
    ItemFactory.clear_item_list
    @item_list = ItemFactory.list
  end

  private
  def compare_item_utility
    item_list.length.times do |x|
      (max_weight + 1).times do |y|
        if(item_list[x].weight > y)
          utility_matrix[x][y] = utility_matrix[x-1][y]
        else
          if utility_matrix[x-1][y] > (item_list[x].value + utility_matrix[x-1][y-(item_list[x].weight)])
            utility_matrix[x][y] = utility_matrix[x-1][y]
          else
            utility_matrix[x][y] = (item_list[x].value + utility_matrix[x-1][y-(item_list[x].weight)])
          end
        end
      end
    end
  end

  def find_selected_items
    current_total = utility_matrix[0].length - 1
    @selected     = utility_matrix.map {0}

    (utility_matrix.length - 1).downto(0) do |i|
      break if current_total < 0
      if (i == 0 && utility_matrix[i][current_total] > 0) || (utility_matrix[i][current_total] != utility_matrix[i-1][current_total])
        selected[i] = 1
        current_total -= item_list[i].weight
      end
    end
  end
end

# Create the Knapsack itself
class Knapsack
  attr_accessor :item_list,:selected_items,:utility_matrix
  attr_reader   :total_value,:total_weight,:item_names
  def initialize(item_list,selected_items,utility_matrix)
    @item_list      = item_list
    @selected_items = selected_items
    @utility_matrix = utility_matrix
  end

  def pack_knapsack # Calculates the final weights and values once names and utilities are known
    @item_names   = list_selected_items
    @total_weight = find_total_weight
    @total_value  = utility_matrix.last.last
  end

  def find_total_weight
    item_list.zip(selected_items).map { |item,selected| item.weight*selected }.inject(:+)
  end

  def list_selected_items
    item_list.zip(selected_items).map { |item,selected| item.name if selected > 0 }.compact*(', ')
  end

  def print_solution # All values can also be accessed individually or via this output method
    ["The following items will be packed: #{item_names}","Weighing: #{total_weight}","And valued at: #{total_value}"].each { |val| puts val }
  end
end

# Test data - will also accept an array of arrays
items = [
  { name: 'map',      weight: 9,   value: 150 },
  { name: 'compass',  weight: 13,  value:  35 },
  { name: 'water',    weight: 153, value: 200 },
  { name: 'snackbar', weight: 50,  value: 160 },
  { name: 'canteen',  weight: 15,  value:  60 },
  { name: 'cookware', weight: 68,  value:  45 },
  { name: 'banana',   weight: 27,  value:  60 },
  { name: 'apple',    weight: 39,  value:  40 },
  { name: 'snacks',   weight: 23,  value:  30 },
  { name: 'soda',     weight: 52,  value:  10 },
  { name: 'lotion',   weight: 11,  value:  70 },
  { name: 'camera',   weight: 32,  value:  30 },
  { name: 'shirt',    weight: 24,  value:  15 },
  { name: 'pants',    weight: 48,  value:  10 },
  { name: 'umbrella', weight: 73,  value:  40 },
  { name: 'pants',    weight: 42,  value:  70 },
  { name: 'coat',     weight: 43,  value:  75 },
  { name: 'notebook', weight: 22,  value:  80 },
  { name: 'glasses',  weight: 7,   value:  20 },
  { name: 'towel',    weight: 18,  value:  12 },
  { name: 'socks',    weight: 4,   value:  50 },
  { name: 'book',     weight: 30,  value:  10 }
]

backpacker = BackPacker.new(items,400)
backpacker.get_items
backpacker.get_knapsack_vals
backpacker.select_appropriate_knapsack
backpacker.knapsack.pack_knapsack
backpacker.knapsack.print_solution
