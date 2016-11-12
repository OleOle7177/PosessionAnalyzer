require_relative 'possession_writer'
require_relative 'possession_summary'
require_relative 'data_extractor'
require 'csv'

class Analyzer
  include PossessionWriter
  include PossessionSummary
  include DataExtractor

  def initialize(csv_file_address)
    @csv_file_address = csv_file_address
    @previous_second = nil
    @current_second = new_nested_hash

    @result_hash = new_nested_hash
  end

  def perform
    ::CSV.foreach(@csv_file_address, skip_blanks: true).with_index do |row, i|
      process_row(row, i)
    end

    count_possession_summary
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

  # define team keys if they are not presented in second data
  def define_teams_keys(row)
    if !@current_second.has_key?('team_id_1')
      @current_second['team_id_1'] = @result_hash['team_id_1'] = row['team_id']
    elsif (row['team_id'] != @current_second['team_id_1'] && !@current_second.has_key?('team_id_2'))
      @current_second['team_id_2'] = @result_hash['team_id_2'] = row['team_id']
    end
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

  # initialize new current second with start values
  def initialize_current_second(row)
    @current_second['number'] = row['second']
    @current_second['team_id_1'] = @previous_second['team_id_1']
    @current_second['team_id_2'] = @previous_second['team_id_2']

    @current_second[@current_second['team_id_1']]['ball_distance'] = 500
    @current_second[@current_second['team_id_2']]['ball_distance'] = 500

    @current_second['ball_coords'] = @previous_second['ball_coords']
  end

  def new_nested_hash
    Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }
  end

  def count_possession_summary
    count_summary_for_team(@result_hash['team_id_1'])
    count_summary_for_team(@result_hash['team_id_2'])

    @result_hash
  end

  def count_summary_for_team(team_id)
    @result_hash[team_id].each do |k, v|
      @result_hash[team_id][k]['sum_total_possession'] =
        count_sum_possession('total_possession', v)
    end

    @result_hash[team_id].each do |k, v|
      @result_hash[team_id][k]['sum_clean_possession'] =
        count_sum_possession('clean_possession', v)
    end
  end

  def count_sum_possession(possession_type, value)
    sum = 0
    value[possession_type].map{|r| sum += r[1]}
    sum
  end

end
