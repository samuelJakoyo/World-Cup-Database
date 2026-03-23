#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# truncating the data
echo $($PSQL "truncate teams, games")

# reading the CSV file 
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # skip header
  if [[ $YEAR != "year" ]]
  then
    # get winning team_id
    WINNING_TEAM_ID=$($PSQL "select team_id from teams where name='$WINNER'")

    # if not found
    if [[ -z $WINNING_TEAM_ID ]]
    then
      INSERT_WINNING_TEAM=$($PSQL "insert into teams(name) values('$WINNER')")
      if [[ $INSERT_WINNING_TEAM == "INSERT 0 1" ]]
      then
        echo "Inserted into teams, $WINNER"
      fi

      WINNING_TEAM_ID=$($PSQL "select team_id from teams where name='$WINNER'")
    fi

    # get opponent_id
    OPPONENT_ID=$($PSQL "select team_id from teams where name='$OPPONENT'")

    # if not found
    if [[ -z $OPPONENT_ID ]]
    then
      INSERT_OPPONENT=$($PSQL "insert into teams(name) values('$OPPONENT')")
      if [[ $INSERT_OPPONENT == "INSERT 0 1" ]]
      then
        echo "Inserted into teams, $OPPONENT"
      fi

      OPPONENT_ID=$($PSQL "select team_id from teams where name='$OPPONENT'")
    fi

    # insert game results
    GAME_RESULTS=$($PSQL "insert into games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) values($YEAR,'$ROUND',$WINNING_TEAM_ID,$OPPONENT_ID,$WINNER_GOALS,$OPPONENT_GOALS)")

    if [[ $GAME_RESULTS == "INSERT 0 1" ]]
    then
      echo "Inserted into games"
    fi
  fi  
done
