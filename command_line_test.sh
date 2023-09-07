#!/bin/bash

#The project's directory
dir=~/"ECEP/LinuxSystems/Projects/.TestData/"
credentials_file=.user_credentials.csv #File for credentials
credentials_dir=$dir$credentials_file #Path to the credentials file
question_bank_file=.question_bank.csv #File for the questions
question_bank_dir=$dir$question_bank_file #Path to the questions file


	if [ ! -d "$dir" ] #If The directory does not exist then it's created
	then
		mkdir -p $dir
	fi


	if [ ! -f $credentials_dir ] #If the file does not exist then it's created
	then
		touch $credentials_dir
	fi

function menu_header()
{
	echo "My Command Line Test"
}


function test_screen()
{
	local username=$1 #Logged user's name
	local user_file="${username}_answer_file.csv" #File for user's answers
	local bak_file=".${username}_answer_file.bak" #Backup file for user's answers
	local user_file_dir=$credentials_dir$user_file #Path to the answers file
	local bak_file_dir=$credentials_dir$bak_file #Path to the backup file
	local question_number=1
	local remaining=10

	if [ ! -f $user_file_dir ]
	then
		touch $user_file_dir
	fi

	if [ ! -f $bak_file_dir ]
	then
		touch $bak_file_dir
	fi

	IFS=$'\n' #Condition for reading the data as the whole lines
	shuffled_lines=($(sort -R "$question_bank_dir")) #Array with the random sort of the questions

		for line in "${shuffled_lines[@]}" #A loop for reading the lines
		do
			remaining=10 #Resetting the timer at the start of the next question
			IFS=',' read -ra words <<< "$line" #Reading the lines
			while [ $remaining -gt 0 ] #The loop for the timer
			do
			clear #Clearing the terminal so the counter works
			menu_header
			echo -e "Time remaining: $remaining seconds" #Displaying the time left
			echo ""
			echo ""
			echo -n "$question_number. "
			for word in "${words[@]}" #Loop for outputting the question and the option each on the new line
			do
				echo "$word"
			done
				echo -ne "\rChoose your option: "
            			if read -t 1 -n 1 -r -s answer
				then
					break #Breaking the loop therefore moving to another question
				fi
				remaining=$((remaining - 1)) #Decreasing the time left
        		done
			((question_number++)) #Increse of the number of the question
		done

}

function test_menu()
{
	local option
	local username=$1

	echo ""
	menu_header

        while true
        do
                echo ""
                echo "1. Take a test"
                echo "2. View a test"
                echo "3. Exit"

                echo ""
                if read -p "Please choose your option: "  option
                then

                        if [[ "$option" -eq 1 ]]
                        then
                                test_screen "$username"
                        elif [[ "$option" -eq 2 ]]
                        then
                               	view_test_screen "$username"
                        elif [[ "$option" -eq 3 ]]
                        then
                                exit 0
                        else
                                echo ""
                                echo "Invalid input!"
                                echo ""
                        fi
                fi
        done
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
					test_menu "$username"
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
	local option

	menu_header

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
			fi
		else
			echo ""
			exit 1
		fi
	done
}

main
