module PosessionWriter

  protected

  def analyze_posession(row, previous_second, current_second)
    if current_second['summary']
      #player starts posession
      if player_start_posession(previous_second, current_second)
        @total_int = 0
        start_write_posession(previous_second, current_second, 'total_posession')
        if current_second['summary']['posession']['clean'] == true
          start_write_posession(previous_second, current_second, 'clean_posession')
          @clean_int = 0
        end
      end

        # player continues posession
        if player_continue_posession(previous_second, current_second)
          @total_int += 1
          continue_write_posession(previous_second, current_second, 'total_posession')

          if current_second['summary']['posession']['clean'] == true
            # if there are no intervals of dirty posession in current interval
            if @total_int == @clean_int
              continue_write_posession(previous_second, current_second, 'clean_posession')
              @clean_int += 1
            end
          else
            @clean_int = 0
          end
        end
    end

  end

  def player_start_posession(previous_second, current_second)
    previous_second.nil? ||
    previous_second['summary'].nil? ||
    player_changed(previous_second, current_second) ||
    more_than_one_second_passed(previous_second, current_second)
  end

  def player_continue_posession(previous_second, current_second)
    !player_changed(previous_second, current_second) &&
    !more_than_one_second_passed(previous_second, current_second)
  end

  def start_write_posession(previous_second, current_second, posession_type)
    # if no posession info about this player given, create an empty posession array
    if @result_hash[current_second['summary']['team_id']][current_second['summary']['player_id']][posession_type].empty?
      posession = @result_hash[current_second['summary']['team_id']][current_second['summary']['player_id']][posession_type] = []
    end

    @result_hash[current_second['summary']['team_id']][current_second['summary']['player_id']][posession_type] << [current_second['number'], 1]
  end

  def continue_write_posession(previous_second, current_second, posession_type)
    @result_hash[current_second['summary']['team_id']][current_second['summary']['player_id']][posession_type].last[1] += 1
  end

  def more_than_one_second_passed(previous_second, current_second)
    return false if previous_second.nil?
    current_second['number'] - previous_second['number'] > 1
  end

  def player_changed(previous_second, current_second)
    if previous_second.nil?
      true
    elsif previous_second['summary'].nil?
      true
    elsif (current_second['summary']['player_id'] != previous_second['summary']['player_id'])
      true
    else
      false
    end
  end

end
