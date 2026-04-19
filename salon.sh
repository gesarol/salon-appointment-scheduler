#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo -e "\nWelcome to My Salon, how can I help you?\n"

SERVICE_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n"$1
  fi

  services=$($PSQL "SELECT service_id, name FROM services;")
  # list services
  echo "$services" | while IFS="|" read service_id service_name
  do
    echo "$service_id) $service_name"
  done

  # select a service
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
  # if not found
  if [[ -z $SERVICE_NAME ]]
  then
    # return to service menu
    SERVICE_MENU "I could not find that service. What would you like today?"
  else
    # get customer phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")
    # if not exist
    if [[ -z $CUSTOMER_NAME ]]
    then
      # ask for customer's name
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      # add customer to the database
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
    fi
    # get customer id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")

    # get the time of appointment
    echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME

    # insert appointment into database
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")
    if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]
    then
      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi

  fi
}

SERVICE_MENU