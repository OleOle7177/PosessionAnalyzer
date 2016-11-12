module PossessionSummary

  def add_summary_for_current_second
    @current_second['summary'] = nil

    first_dist = @current_second[@current_second['team_id_1']]['ball_distance']
    second_dist = @current_second[@current_second['team_id_2']]['ball_distance']

    possession = check_possession(first_dist, second_dist)

    if possession
      team_id = @current_second['team_id_1']
    else
      possession = check_possession(second_dist, first_dist)
      team_id = @current_second['team_id_2'] if possession
    end

    add_summary(team_id, possession) if team_id
  end

  def add_summary(team_id, possession)
    @current_second['summary'] = {
      'team_id' => team_id,
      'player_id' => @current_second[team_id]['player_id'],
      'possession' => possession
    }
  end

  def check_possession(length1, length2)
    if length1 < 1 && (1..4).member?(length2)
      { 'clean' => false, 'dirty' => true }
    elsif length1 < 1 && length2 > 4
      { 'clean' => true, 'dirty' => false }
    else
      false
    end
  end

end
