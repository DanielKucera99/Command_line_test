#!/bin/bash

#The project's directory
dir=~/"ECEP/LinuxSystems/Projects/.TestData/"
credentials_file=.user_credentials.csv #File for credentials
credentials_dir=$dir$credentials_file #Path to the credentials file
question_bank_file=.question_bank.csv #File for the questions
question_bank_dir=$dir$question_bank_file #Path to the questions file
log_file=command_line_test.log
log_file_dir=$dir$log_file

	if [ ! -d "$dir" ] #If The directory does not exist then it's created
	then
		mkdir -p "$dir"
	fi
	if [ ! -f "$log_file_dir" ]
	then
		touch "$log_file_dir"
	fi

	if [ ! -f "$credentials_dir" ] #If the file does not exist then it's created
	then
		touch "$credentials_dir"
		echo "$(date '+%Y-%m-%d %H:%M:%S') - Created ${credentials_file}" >> "$log_file_dir"
	fi

function menu_header()
{
	echo "My Command Line Test"
}
function answer_file_creation()
{
	local username=$1
	local user_file="${username}_answer_file.csv" #File for user's answers
	local bak_file=".${username}_answer_file.bak" #Backup file for user's answers
	local user_file_dir=$dir$user_file #Path to the answers file
	local bak_file_dir=$dir$bak_file #Path to the backup file

	if [ ! -f $user_file_dir ] #Creation of the answer file
	then
		touch $user_file_dir
		echo "$(date '+%Y-%m-%d %H:%M:%S') - Created ${user_file_dir}" >> "$log_file_dir"
	fi

	if [ ! -f $bak_file_dir ] #Creation of the backup file
	then
		touch $bak_file_dir
		echo "$(date '+%Y-%m-%d %H:%M:%S') - Created ${bak_file_dir}" >> "$log_file_dir"
	fi
}

function view_test_screen()
{
	local username=$1
	local answer_file=$dir"${username}_answer_file.csv"
	local answer_string="answer"
	local red_color="\e[31m"
	local reset_color="\e[0m"

	echo "$(date '+%Y-%m-%d %H:%M:%S') - User ${username} viewed a test" >> "$log_file_dir"

	clear
	menu_header

	if [ ! -s "$answer_file" ] #If the answer file is empty it means that the user didn't take a test yet
	then
		echo -e  "\nYou didn't take the test yet"
		read -n 1 -s -p "Press any key to go back: " key
	else

		while IFS= read -r file_line #Loop for displaying the lines from the answer file
		do
    			if [[ "$file_line" == *"$answer_string"* ]] #If the line contains the string than it is colored in red
			then
        			echo -e "${red_color}${file_line}${reset_color}" #The red print
    			else
        			echo "$file_line" #The regular print
    			fi
		done < "$answer_file"

		echo ""
		read -n 1 -s -p "More: Hit any key to continue "
	fi
}

function test_screen()
{
	local username=$1 #Logged user's name

	answer_file_creation "$username" #Creation of the backup and answer files
	local question_number=1
	local remaining=10
	local answer_file=$dir"${username}_answer_file.csv"
	local bak_file=$dir".${username}_answer_file.bak"

	echo "$(date '+%Y-%m-%d %H:%M:%S') - User ${username} took a test" >> "$log_file_dir"

	if [ -s "$answer_file" ] #If the answer file contains the answers from the previous try, copy it into the backup file
	then
		cat "$answer_file" > "$bak_file"
		echo "$(date '+%Y-%m-%d %H:%M:%S') - Answer file was copied into a backup file" >> "$log_file_dir"
	fi

	truncate -s 0 "$answer_file" #If the answer file contains the answers from the previous try then it's cleared

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
			if [ $remaining -eq 10 ] #Condition for writing the string only once per question
			then
				echo "$question_number." >> "$answer_file" #Writing the question number to the file
			fi
			for word in "${words[@]}" #Loop for outputting the question and the option each on the new line
			do
				echo "$word"
				if [ $remaining -eq 10 ] #Same as above
				then
				echo "$word" >> "$answer_file" #Writing the question and the answers to the file
				fi
			done
				echo -ne "\rChoose your option: "
            			if read -t 1 -n 1 -r -s answer #Reading the answer
				then
					case $answer in
					"a" | "b" | "c" | "d")
						local time_of_answer=$((10 - remaining)) #The time within the user answered
						local answer_string=" -> You answered within $time_of_answer seconds" #String that will be appended to the answer in the file
						local matching_lines=$(grep -nF "[$answer]" "$answer_file" | cut -d':' -f1) #Searching for the lines containing the answer
						local last_line=""
						for line_number in $matching_lines #Loop for finding the last line in the containing the answer -> the last line belongs to the current question
						do
							last_line="$line_number"
						done

						if [ -n "$last_line" ] #Check whether is last line is not empty
						then
   							sed -i "${last_line}s/$/ $answer_string/" "$answer_file" #Appending the string to the answer in the answer file
						fi
						;;
					*)
						echo -e "\nYour answer is invalid!\n" >> "$answer_file"
						;;
					esac
					break  #Breaking the loop therefore moving to another question
				fi
				if [ $((remaining - 1)) -eq 0 ]
				then
				echo -e "\nYou didn't answer this question!\n" >> "$answer_file"
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

        while true
        do
		clear
		menu_header
                echo ""
                echo "1. Take a test"
                echo "2. View a test"
                echo "3. Exit"

                echo ""
                if read -n 1 -s -p "Please choose your option: "  option #Reading the input of the logged user
                then

                        if [[ "$option" -eq 1 ]]
                        then
                                test_screen "$username"
                        elif [[ "$option" -eq 2 ]]
                        then
                               	view_test_screen "$username"
                        elif [[ "$option" -eq 3 ]]
                        then
				echo "$(date '+%Y-%m-%d %H:%M:%S') - User $username exited" >> "$log_file_dir"
                                break
                        else
                                echo -e "\nInvalid input!\n"
                        fi
                fi
        done
}

function sign_in()
{
	clear
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

		local pattern="^[[:alnum:]]+$" #Pattern that contains only alphanumeric characters

		if  [[ $username =~ $pattern ]] #Checking whether provided string contains only alphanum characters
		then
			if grep -m 1 -o -q "\\b$username\\b" "$credentials_dir" #Checking whether the username is in the credentials file
			then
				while true
				do
				salt=$(grep "^$username," "$credentials_dir" | cut -d',' -f3) #Searching for the salt that belongs to the user
				read -s -p "Password: " pass
					hashed_pass=$(openssl passwd -6 -salt "$salt" "$pass") #Hashing the pass the same way the sign up did
					if grep  "^$username," "$credentials_dir" | cut -d',' -f2 | grep -q "$hashed_pass" #Testing whether the passes match
					then
						echo "$(date '+%Y-%m-%d %H:%M:%S') - User $username succesully signed in" >> "$log_file_dir"
						test_menu "$username"
						break #Breakinf from the login loop when the test menu is exited
					else
						echo ""
						echo -e "\033[31mInvalid password!!!\033[0m"
					fi
				done
			else
				echo -e "\033[31mUsername $username does not exists!!!\033[0m"
				echo ""
			fi
			break #If user exits then it's brought back to the menu
		else
			echo -e "\033[31mUsername $username does not exists!!!\033[0m"
                        echo ""
		fi
	done

}

function sign_up()
{
	clear
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
		local pattern="^[[:alnum:]]+$" #Condition for only alphanumeric username

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
					if [ ${#pass} -gt 7 ] #Length of the pass
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
									read -n 1 -s -r -p "Registration sucessfull. Please hit any key to continue " key
									if [ "$key" ]
									then
										echo ""
										break #Break from the pass loop
									fi
								else
									echo -e "\nThe passwords do not match!"
								fi
							else
								echo -e "\nThe password must contain a special symbol"
							fi
						else
							echo -e "\nThe password must contain a number"
						fi
					else
						echo -e "\nThe password must be at least 8 characters long"
					fi
				done #End of the pass loop
				echo "$(date '+%Y-%m-%d %H:%M:%S') - User ${username} created" >> "$log_file_dir"
				break #Break from the user loop
			fi
		else
			echo -e "\nThe username must contain only alphanumeric symbols!\n"
		fi

	done #End of the user loop
}

function main()
{
	local option

	echo "$(date '+%Y-%m-%d %H:%M:%S') - Script invoked" >> "$log_file_dir"
	while true
	do
		clear
		menu_header
		echo "Please choose the option below"

		echo ""
		echo "1. Sign in"
		echo "2. Sign up"
		echo "3. Exit"

		echo -e "\nNote: Script Exit Timeout is set\n"

		if read -n 1 -s -p "Please choose your option: " -t 10 option #Reading the input at the start of the program; if it is not answered in 10 seconds, the program closes
		then

			if [[ "$option" -eq 1 ]]
			then
				sign_in
			elif [[ "$option" -eq 2 ]]
			then
				sign_up
			elif [[ "$option" -eq 3 ]]
			then
				echo ""
				echo "$(date '+%Y-%m-%d %H:%M:%S') - Script exited" >> "$log_file_dir"

				exit 0
			else
				echo -e "\nInvalid input!\n"
			fi
		else
			echo ""
			echo "$(date '+%Y-%m-%d %H:%M:%S') - Script timed out!!!" >> "$log_file_dir"
			exit 1
		fi
	done
}

main
