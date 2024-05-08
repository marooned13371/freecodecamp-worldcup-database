#!/bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

echo $($PSQL "TRUNCATE games, teams")
echo $($PSQL "ALTER SEQUENCE games_game_id_seq RESTART WITH 1")
echo $($PSQL "ALTER SEQUENCE teams_team_id_seq RESTART WITH 1")

tail -n +2 games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS; do
  if [[ $YEAR != "year" ]]; then

    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
    if [[ -z $WINNER_ID ]]; then
      RESULT_WINNER_ID=$($PSQL "INSERT INTO teams (name) VALUES ('$WINNER') ON CONFLICT (name) DO NOTHING")
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
      if [[ $RESULT_WINNER_ID == "INSERT 0 1" ]]; then
        echo "The winner team '$WINNER' has been inserted in the database"
      fi
    fi

    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
    if [[ -z $OPPONENT_ID ]]; then
      RESULT_OPPONENT_ID=$($PSQL "INSERT INTO teams (name) VALUES ('$OPPONENT') ON CONFLICT (name) DO NOTHING")
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
      if [[ $RESULT_OPPONENT_ID == "INSERT 0 1" ]]; then
        echo "The opponent team '$OPPONENT' has been inserted in the database"
      fi
    fi

    INSERT_GAME_RESULTS=$($PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals)
                                VALUES ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
  fi
done

