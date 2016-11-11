require 'csv'
require 'pry'

class Analyzer

  def initialize(csv_file_address)
    @csv_file_address = csv_file_address
    # @current_second = {
    #   number: nil,
    #   ball_coords: nil,
    #   team_1_id: nil,
    #   team_2_id: nil,
    #   team_1: {
    #     id: {}
    #     player_id: nil,
    #     ball_distance: nil
    #   },
    #   team_2: {
    #     player_id: nil,
    #     ball_distance: nil
    #   }
    # }

    @current_second = Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }

    @result_hash = {}
  end

  def perform
    ::CSV.foreach(@csv_file_address).with_index do |row, i|
      process_row(row, i)
      break if i > 50
    end

    p @current_second
  end

  protected

  def process_row(row, i)
    if i.zero?
      get_headers(row[0])
    else
      row_hash = Hash[@headers.zip get_data(row[0]).map(&:to_i)]
      extract_data(row_hash)
    end
  end

  def extract_data(row)
    # переназначить секунду на следующую
    # и проанализировать какому игроку присвоить
    # предыдущую секунду if row['second'] != @current_second['number']
# {"id"=>"957012591",
#   "match_id"=>"578738",
#   "team_id"=>"0",
#   "player_id"=>"0",
#   "half"=>"1",
#    "second"=>"0",
#    "x"=>"0",
#    "y"=>"35",
#    "distance"=>"7"}
#     row['']
    if row['player_id'].zero?
      #присвоить координаты мяча в каррент секонд
      @current_second['ball_coords']['x'] = row['x']
      @current_second['ball_coords']['y'] = row['y']
    else
      ball_distance = calculate_ball_distance(row['x'], row['y'])
      if check_ball_distance(row, ball_distance)
        @current_second[row['team_id']]['ball_distance'] = ball_distance
        @current_second[row['team_id']]['player_id'] = row['player_id']
      end
    end
  end

  def calculate_ball_distance(x, y)
     delta_x = @current_second['ball_coords']['x'] - x
     delta_y = @current_second['ball_coords']['y'] - y

     Math.sqrt(delta_x ** 2 + delta_y ** 2)
  end

  def check_ball_distance(row, ball_distance)
    @current_second[row['team_id']]['ball_distance'].blank? ||
      (@current_second['team_id']['ball_distance'] > ball_distance)
  end

  def get_data(string)
    string&.split(";\"")&.map{ |x| x.chomp("\"") }
  end

  def get_headers(string)
    @headers = get_data(string)
  end

end
