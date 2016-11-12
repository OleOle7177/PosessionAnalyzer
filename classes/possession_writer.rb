module PossessionWriter

  def analyze_possession(row)
    if @current_second['summary']

      if player_start_possession
        start_possession_handler
      end

      if player_continue_possession
        continue_possession_handler
      end
    end
  end

  def start_possession_handler
    @total_int = 0
    start_write_possession('total_possession')
    if @current_second['summary']['possession']['clean'] == true
      start_write_possession('clean_possession')
      @clean_int = 0
    end
  end

  def continue_possession_handler
    @total_int += 1
    continue_write_possession('total_possession')

    if @current_second['summary']['possession']['clean'] == true
      # if there are no intervals of dirty possession in current interval
      if @total_int == @clean_int
        continue_write_possession('clean_possession')
        @clean_int += 1
      end
    else
      @clean_int = 0
    end
  end

  def player_start_possession
    @previous_second.nil? ||
    @previous_second['summary'].nil? ||
    player_changed ||
    more_than_one_second_passed
  end

  def player_continue_possession
    !player_changed &&
    !more_than_one_second_passed
  end

  def start_write_possession(possession_type)
    # if no possession info about this player given, create an empty possession array
    if @result_hash[@current_second['summary']['team_id']][@current_second['summary']['player_id']][possession_type].empty?
      possession = @result_hash[@current_second['summary']['team_id']][@current_second['summary']['player_id']][possession_type] = []
    end

    @result_hash[@current_second['summary']['team_id']][@current_second['summary']['player_id']][possession_type] << [@current_second['number'], 1]
  end

  def continue_write_possession(possession_type)
    @result_hash[@current_second['summary']['team_id']][@current_second['summary']['player_id']][possession_type].last[1] += 1
  end

  def more_than_one_second_passed
    return false if @previous_second.nil?
    @current_second['number'] - @previous_second['number'] > 1
  end

  def player_changed
    if @previous_second.nil?
      true
    elsif @previous_second['summary'].nil?
      true
    elsif (@current_second['summary']['player_id'] != @previous_second['summary']['player_id'])
      true
    else
      false
    end
  end

end
