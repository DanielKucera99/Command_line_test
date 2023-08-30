#!/bin/bash

#The project's directory
dir=~/"ECEP/LinuxSystems/Projects/"

function menu_header()
{
	echo "My Command Line Test"
}


function sign_in()
{
	menu_header
}

function sign_up()
{
	credentials_file=.user_credentials.csv #File for credentials
	credentials_dir=$dir$credentials_file #Path to that file

	if [ -f $credentials_dir ] #If the file does not exist then it's created
	then
		touch $credentials_dir
	fi

	menu_header
	echo "Sign Up Screen"
	echo ""
	while true #Loop for the case that the username is wrong
	do
		read -p "Please choose your username: " username
		pattern="^[[:alnum:]]+$" #Condition for only alphanumeric username

		if [[ $username =~ $pattern ]]
		then
			while true #Loop for the case the password is worng
			do
				read -s -p "Please enter your password: " pass
				if [ ${#pass} -lt 8 ] #Length of the pass
				then
					if [[ "$pass" =~ [0-9] ]] #Contains number
					then
						if [[ "$pass" =~ [^a-zA-Z0-9] ]] #Contains special symbol
						then
							echo ""
							read -s -p "Please re enter your password: " repass
							if [ "$pass" = "$repass" ] #The passwords match
							then
								echo "$username,$pass" >> $credentials_dir #Appending to a file
								echo ""
								echo ""
								read -n 1 -s -r -p "Registration sucessfull. Please hit any key to continue" key
								if [ "$key" ]
								then
									echo ""
									break #Break from the pass loop
								fi
							else
								echo "The passwords do not match!"
							fi
						else 
							echo "The password must contain a special symbol"
						fi
					else
						echo "The password must contain a number"
					fi
				else
					echo "The password must be at least 8 characters long"
				fi
			done #End of the pass loop
			break #Breal from the user loop 

			else
				echo "The username must contain only alphanumeric symbols!"
				echo ""
			fi
	done #End of the user loop
}

menu_header

if [ ! -d "$dir" ]
then
	mkdir -p $dir
	echo "Dir created"
fi

echo "Please choose the option below"

echo ""
echo "1. Sign in"
echo "2. Sign up"
echo "3. Exit"

echo ""
echo "Note: Script Exit Timeout is set"
echo ""
if read -p "Please choose your option: " -t 10 option
then

	if [[ "$option" -eq 1 ]]
	then
		sign_in
	elif [[ "$option" -eq 2 ]]
	then
		sign_up
	elif [[ "$option" -eq 3 ]]
	then
		break
	fi
else
	echo ""
	exit 1
fi

