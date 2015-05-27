# Based on a CodeEval challenge
# We need to know how many blocks were impacted by a
# helicopter flying over a city. In the city, all blocks
# are rectangular. They are separated by N  straight
# horizontal avenues that run East-West and M straight
# vertical streets which run North-South.
#
# A helicopter from the South-West corner of the city
# flew to the North-East corner. How many city blocks
# did it fly over? You will be given two lists, the first
# one is for streets and the second one is for avenues.
class Brick
  attr_reader :x_coords,:y_coords
  def initialize(x_st_two,x_st_one,y_st_one,y_st_two)
    @x_coords = [x_st_two,x_st_one]
    @y_coords = [y_st_one,y_st_two]
  end
end

class FlightPlan
  attr_accessor :bricks,:num_bricks
  attr_reader   :streets,:aves,:slope
  def initialize(streets,aves)
    @streets    = streets.split(",")
    @aves       = aves.split(",")
    @bricks     = []
    @num_bricks = 0
  end

  def find_slope
    @slope = (aves[aves.length - 1].to_f - aves[0].to_f) / (streets[streets.length - 1].to_f - streets[0].to_f)
  end

  def create_bricks
    (1...aves.length).each { |n| (1...streets.length).each { |m| bricks << Brick.new(streets[m - 1].to_f, streets[m].to_f, aves[n - 1].to_f, aves[n].to_f) } }
  end

  def find_total_bricks
    bricks.map { |brick| @num_bricks += 1 if ((brick.x_coords[0] * slope) < brick.y_coords[1] && (brick.x_coords[1] * slope) > brick.y_coords[0]) }
  end
end

list = "(0,2,4,8,10,13,14,18,22,23,24,33,40,42,44,47,49,53,55,63,66,81,87,91) (0,147,220)"
paths = list.gsub(/[)(]/,"").split(" ")
helicopter_flight = FlightPlan.new(paths[0],paths[1])
helicopter_flight.find_slope
helicopter_flight.create_bricks
helicopter_flight.find_total_bricks
p helicopter_flight.num_bricks
