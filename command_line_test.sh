#!/bin/bash

#The project's directory
dir=~/"ECEP/LinuxSystems/Projects/"
credentials_file=.user_credentials.csv #File for credentials
credentials_dir=$dir$credentials_file #Path to that file

	if [ ! -f $credentials_dir ] #If the file does not exist then it's created
	then
		touch $credentials_dir
	fi

function menu_header()
{
	echo "My Command Line Test"
}

function test_menu()
{
	echo "Test menu"
}

function sign_in()
{
	menu_header

	local username
	local pass
	local salt
	local hashed_pass

	echo "Sign In Screen"
	echo ""
	while true
	do
		echo "Please enter your"
		echo ""
		read -p "Username: " username
		if grep -m 1 -o -q "^$username[^,]*" $credentials_dir #Checking whether the username is in the credentials file
		then
			while true
			do
			salt=$(grep "^$username," "$credentials_dir" | cut -d',' -f3) #Searching for the salt that belongs to the user
			read -s -p "Password: " pass
				hashed_pass=$(openssl passwd -6 -salt "$salt" "$pass") #Hashing the pass the same way the sign up did
				if grep  "^$username," "$credentials_dir" | cut -d',' -f2 | grep -q "$hashed_pass" #Testing whether the passes match
				then
					test_menu
				else
					echo ""
					echo -e "\033[31mInvalid password!!!\033[0m"
				fi
			done
		else
			echo -e "\033[31mUsername $username does not exists!!!\033[0m"
			echo ""
		fi
	done
}

function sign_up()
{

	menu_header

	local username
	local pass
	local hashed_pass
	local salt=$(openssl rand -hex 16) #Random salt

	echo "Sign Up Screen"
	echo ""
	while true #Loop for the case that the username is wrong
	do
		read -p "Please choose your username: " username
		pattern="^[[:alnum:]]+$" #Condition for only alphanumeric username

		if [[ $username =~ $pattern ]]
		then
			if grep -m 1 -o -q "^$username[^,]*" $credentials_dir #Checking whether the user name exists in the csv file
			then
				echo ""
				echo -e "\033[31mUsername $username already exists!!! Please choose some other name\033[0m"
			else
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
									hashed_pass=$(openssl passwd -6 -salt "$salt" "$pass")
									echo "$username,$hashed_pass,$salt" >> $credentials_dir #Appending to a file
									echo ""
									echo ""
									read -n 1 -s -r -p "Registration sucessfull. Please hit any key to continue" key
									if [ "$key" ]
									then
										echo ""
										break #Break from the pass loop
									fi
								else
									echo ""
									echo "The passwords do not match!"
								fi
							else
								echo ""
								echo "The password must contain a special symbol"
							fi
						else
							echo ""
							echo "The password must contain a number"
						fi
					else
						echo ""
						echo "The password must be at least 8 characters long"
					fi
				done #End of the pass loop
				break #Break from the user loop
			fi
		else
			echo ""
			echo "The username must contain only alphanumeric symbols!"
			echo ""
		fi

	done #End of the user loop
}

function main()
{
menu_header

if [ ! -d "$dir" ]
then
	mkdir -p $dir
	echo "Dir created"
fi

while true
do
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
		exit 0
	else
		echo ""
		echo "Invalid input!"
		echo ""
		continue
	fi
else
	echo ""
	exit 1
fi
done
}

main
