#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -X -c"
LIST_SERVICES=$($PSQL "SELECT * FROM services")

##echo -e "\n~~~ Salon apointment ~~~\n"

MAIN_MENU(){
echo -e "\nAvaliable services\n"
if [[ -z $LIST_SERVICES ]]
then
  echo -e "\nNo services available"
  EXIT
else
  echo "$LIST_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  MAKE_APPOINTMENT
fi
}

MAKE_APPOINTMENT(){
echo -e "\nInsert selected service"
read SERVICE_ID_SELECTED
# Check if service exists
if [[ SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
then
  echo "This is not a number"
else
  SERVICE_SELECTED_RESULT=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_SELECTED_RESULT ]]
  then
    echo wrong
    MAIN_MENU "The service does not exist."
  else
    echo -e "\nInsert your phone number"
    read CUSTOMER_PHONE
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_ID ]]
    then
      echo -e "\nCustomer not registered, insert your name"
      read CUSTOMER_NAME
      REGISTER_CUSTOMER=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      echo -e "\nCustomer created successfully\n"
    else
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    fi
    echo -e "\nInsert the time to schedule the appointment"
    read SERVICE_TIME
    CREATE_APPOINTMENT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    if [[ $CREATE_APPOINTMENT = "INSERT 0 1" ]]
    then
      echo "I have put you down for a $SERVICE_SELECTED_RESULT at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
fi
}

EXIT(){
  echo -e "\nWe look forward to seeing you again"
}

MAIN_MENU
