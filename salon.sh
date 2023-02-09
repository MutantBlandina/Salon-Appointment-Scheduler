#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

# display list of services

echo -e "\n~~~~~ Salon ~~~~~\n"

MAIN_MENU() {
  # get list of services
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "Here are the services we offer:"
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  
  echo -e "\nSelect your service"

  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
    1) BOOKING_MENU ;;
    2) BOOKING_MENU ;;
    3) BOOKING_MENU ;;
    *) MAIN_MENU "Please enter a valid option." ;;
  esac
}

BOOKING_MENU() {
  # enter a service_id
  
  # if input is not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # send to main menu
    MAIN_MENU "That is not a valid service number."
  else
    # get service name
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/^ //')
  
    # phone number
    echo -e "\nPlease enter your phone number"
    read CUSTOMER_PHONE
    
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    # if customer doesn't exist
    if [[ -z $CUSTOMER_ID ]]
    then
      # ask for a name
      echo -e "\nPlease enter your name"
      read CUSTOMER_NAME
      INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    else
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    fi

    CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/^ //')

    # ask for a time
    echo -e "\nFor what time would you like to book this service?"
    read SERVICE_TIME
    INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES($SERVICE_ID_SELECTED, $CUSTOMER_ID, '$SERVICE_TIME')")

    echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
  fi
}

MAIN_MENU
