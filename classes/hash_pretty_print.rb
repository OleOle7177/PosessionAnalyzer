class HashPrettyPrint

  def analyzed_hash_print(hash)
    print_team_data(hash, hash['team_id_1'])
    print_team_data(hash, hash['team_id_2'])
  end

  def print_team_data(hash, team_id)
    p "TEAM_ID: #{team_id}"
    hash[team_id].each do |k, v|
      p "player_id: #{k}"
      p "total possession summary: #{readable_time(v['sum_total_possession'])}:"
      print_possession_intervals(v['total_possession'])

      p "clean possession summary: #{readable_time(v['sum_clean_possession'])}:"
      print_possession_intervals(v['clean_possession'])

      puts
    end

    puts
  end

  def print_possession_intervals(data)
    data.each do |time|
      p "#{readable_time(time[0])} - #{readable_time(time[1] + time[0])}"
    end
  end

  def readable_time(time_in_seconds)
    Time.at(time_in_seconds).utc.strftime("%Mm %Ss")
  end

end
