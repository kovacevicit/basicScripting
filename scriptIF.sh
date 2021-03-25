#!/bin/bash

echo "Demonstracija IF i AND logike"
echo "---------------------------------"

echo "Enter username: "
read username
echo "Enter password: "
read password

if [[ ($username == "admin" && $password == "pass" ) ]]; then
echo "Valid user"
echo "Do top secret commands"
else
echo "User not valid"
echo "Why are you trying to hack the system"
fi

