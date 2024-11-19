#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Check if argument is provided
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit
fi

# Function to query element information
get_element_info() {
  # If input is a number (atomic number)
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    ELEMENT=$($PSQL "SELECT atomic_number, symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius, types.type 
                     FROM elements 
                     INNER JOIN properties USING(atomic_number) 
                     INNER JOIN types USING(type_id) 
                     WHERE atomic_number=$1")
  else
    # If input is a symbol or name
    ELEMENT=$($PSQL "SELECT atomic_number, symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius, types.type 
                     FROM elements 
                     INNER JOIN properties USING(atomic_number) 
                     INNER JOIN types USING(type_id) 
                     WHERE symbol='$1' OR name='$1'")
  fi
  
  # If element not found
  if [[ -z $ELEMENT ]]
  then
    echo "I could not find that element in the database."
    exit
  fi

  # Parse the returned pipe-delimited data and format the output
  echo "$ELEMENT" | while IFS="|" read ATOMIC_NUMBER SYMBOL NAME MASS MELTING_POINT BOILING_POINT TYPE
  do
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
  done
}

get_element_info "$1"