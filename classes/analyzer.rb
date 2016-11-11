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
    @previous_second = nil
    @current_second = new_nested_hash

    @result_hash = {}
  end

  def perform
    ::CSV.foreach(@csv_file_address, skip_blanks: true).with_index do |row, i|
      process_row(row, i)
      break if i > 60
    end

    p @previous_second
    p @current_second
  end

  protected

  def process_row(row, i)
    if i.zero?
      get_headers(row[0])
    else
      row_hash = Hash[@headers.zip get_data(row[0]).map(&:to_i)]
      p row_hash
      extract_data(row_hash)
    end
  end

  def extract_data(row)
    # if row['second'] != @current_second['number'] || !@current_second.has_key
    @current_second['number'] = row['second'] unless @current_second.has_key?('number')

    if row['second'] != @current_second['number']
      add_summary_for_current_second
      # проанализировать и назначить
      analyze_posession(row) #if @previous_second
      @current_second = new_nested_hash
      @current_second['number'] = row['second']
      @current_second['ball_coords'] = @previous_second['ball_coords']
    end

    if row['player_id'].zero?
      #присвоить координаты мяча в каррент секонд
      @current_second['ball_coords']['x'] = row['x']
      @current_second['ball_coords']['y'] = row['y']
    else

      define_teams_keys(row)


      ball_distance = calculate_ball_distance(row['x'], row['y'])
      init_ball_distance_for_team(row)

      if @current_second[row['team_id']]['ball_distance'] > ball_distance
        @current_second[row['team_id']]['ball_distance'] = ball_distance
        @current_second[row['team_id']]['player_id'] = row['player_id']
      end
    end
  end

  # define team keys if they are not presented in second data
  def define_teams_keys(row)
    if !@current_second.has_key?('team_id_1')
      @current_second['team_id_1'] = row['team_id']
    elsif (row['team_id'] != @current_second['team_id_1'] && !@current_second.has_key?('team_id_2'))
      @current_second['team_id_2'] = row['team_id']
    end
  end

  def add_summary_for_current_second
    first_dist = @current_second[@current_second['team_id_1']]['ball_distance']
    second_dist = @current_second[@current_second['team_id_2']]['ball_distance']

    posession = check_posession(first_dist, second_dist)
    @current_second['summary'] = nil

    if posession
      team_id = @current_second['team_id_1']
    else
      posession = check_posession(second_dist, first_dist)
      team_id = @current_second['team_id_2'] if posession
    end

    add_summary(team_id, posession) if team_id
  end

  def add_summary(team_id, posession)
    @current_second['summary'] = {
      'team_id' => team_id,
      'player_id' => @current_second[team_id]['player_id'],
      'posession' => posession,
    }
  end

  def check_posession(length1, length2)
    if length1 < 1 && (1..4).member?(length2)
      { 'clean' => false, 'dirty' => true }
    elsif length1 < 1 && length2 > 4
      { 'clean' => true, 'dirty' => false }
    else
      false
    end
  end

  def dirty_posession(length1, length2)

  end

  def analyze_posession(row)
    p 'TIME TO ANALYZE'
    # if @current_second[row['team_id']] != @previous_second
  end

  def calculate_ball_distance(x, y)
     delta_x = @current_second['ball_coords']['x'] - x
     delta_y = @current_second['ball_coords']['y'] - y

     Math.sqrt(delta_x ** 2 + delta_y ** 2)
  end

  def init_ball_distance_for_team(row)
    unless @current_second[row['team_id']].has_key?('ball_distance')
      @current_second[row['team_id']]['ball_distance'] = 500
    end
  end

  def get_data(string)
    string&.split(";\"")&.map{ |x| x.chomp("\"") }
  end

  def get_headers(string)
    @headers = get_data(string)
  end

  def new_nested_hash
    Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }
  end

end
