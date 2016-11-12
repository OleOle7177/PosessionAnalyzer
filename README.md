#Possession Analyzer

## Usage
Run script:
```
$ ruby main.rb /path/to/data_file.csv
```
Result hash will be printed as output.

## Basic logic

1) Build hash with information for each second given in CSV.
It looks like this:
```
{"number"=>2136,
  "team_id_1"=>1,
  "team_id_2"=>2,
  1=>{
    "ball_distance"=>0.0,
    "player_id"=>151
    },
  2=>{
    "ball_distance"=>4.0,
    "player_id"=>4359
    },
  "ball_coords"=>{"x"=>-2, "y"=>49},
  "summary"=>{
    "team_id"=>1,
    "player_id"=>151,
    "possession"=>{
      "clean"=>false,
      "dirty"=>true}
      }
    }
  }
```
'number' - number of current second,
'team_id_...' - team_ids for given match,
'1', '2' - for each team_id value we have keys, containing:
'ball_distance' - distance of closest player to the ball (calculated with simple
  vector length formula) ,
'player_id' - id of the player, closest to the ball

We store information about previous and current second only.

2) Reading CSV row by row we update info about teams closest players and distances to the ball.
Then we catch the moment when second is changing and analyze ended second situation if there
was a clean or dirty possession or no possession at all given: add 'summary' key to second-info hash(see the hash).

3) Comparing to previous second data we have two cases:
- player starts to possess the ball
- player continues to possess

Then:
- If current possession is clean and there were no dirty possession in current interval of player's
possession
=> start/continue clean possession counter.

- If current possession is dirty or
- current position is clean and there were dirty possession moments in current
player's possession time interval
=> start/continue total possession counter.

4) At the end we walk through result hash and count summary for total and clean possession
intervals for every team and every player.

5) Print result hash to the screen.

6) Enjoy.

## Tests
No tests written yet:/
