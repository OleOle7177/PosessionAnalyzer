module PosessionSummary

  def add_summary_for_current_second
    @current_second['summary'] = nil

    first_dist = @current_second[@current_second['team_id_1']]['ball_distance']
    second_dist = @current_second[@current_second['team_id_2']]['ball_distance']

    posession = check_posession(first_dist, second_dist)

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
      'posession' => posession
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

end
