module DataExtractor

  def extract_data(row)
    @current_second['number'] = row['second'] unless @current_second.has_key?('number')

    if row['second'] != @current_second['number']
      add_summary_for_current_second
      analyze_possession(row)
      @previous_second = @current_second.dup
      @current_second = new_nested_hash

      initialize_current_second(row)
    end

    if row['player_id'].zero?
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

  def get_data(string)
    string&.split(";\"")&.map{ |x| x.chomp("\"") }
  end

  def get_headers(string)
    @headers = get_data(string)
  end

end
