module PosessionWriter

  def analyze_posession(row, current_second, previous_second)
    # current second has posession
    if current_second['summary']

      # player changed
      write_total_posession(current_second)

      if (previous_second.nil? || previous_second['summary'].nil?)
        write_clean_posession(current_second)
      end

      if previous_second && previous_second['summary']
        if player_changed_and_posess_clean(previous_second, current_second)
          write_clean_posession(current_second)
        end
      end

    end

    p @result_hash
  end

  def write_total_posession(current_second)
    p 'WRITE'
    # @result_hash[current_second]
    # write_total_posession(current_second)
    # write_clean_posession(current_second) if posession_clean(@current_second)
  end

  def write_clean_posession(current_second)
  end

  def player_changed_and_posess_clean(previous_second, current_second)
    (previous_second['summary']['player_id'] == current_second['summary']['player_id']) &&
      (previous_second['summary']['posession']['clean'] == true)
  end
end
