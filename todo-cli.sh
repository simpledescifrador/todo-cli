
#!/bin/bash

# Created BY EDISON VILLARTA 
# Tue Mar 19 2019

#colors
default_highlight="\e[49m"
white_text="\e[97m"
blue_highlight="\e[44m"
green_highlight="\e[42m"
red_highlight="\e[41m"
yellow_highlight="\e[43m"
green_text="\e[32m"
red_text="\e[31m"
blue_text="\e[96m"
bold_text="\e[1m"
hidden_text="\e[8m"
reset_attr="\e[0m"
blink_text="\e[5m"
DATA_FILE=".todo_store.txt" #Data storage for todo lists

# TODO functions
# 1st ARGS
# RETURN
new_todo()
{
	valid=0

	TEXT=$1

	if [ $3 -le 0 ]; then # 0 and negative is invalid
		((valid=0)); echo -e ${red_text}"$3 is invalid due"${reset_attr} ; return
	elif [ $3 -gt 24 ]; then
		((valid=0)); echo -e ${red_text}"$3 is invalid due"${reset_attr} ; return
	else
		((valid=1)) ##Valid continue process
	fi

	DUE_DATE=$3

	if [ $valid -eq 1 ]; then
		case $2 in
			[Hh]|"High") save_tofile "$DATA_FILE" "$TEXT" "High" $DUE_DATE;;
			[Nn]|"Normal")  save_tofile "$DATA_FILE" "$TEXT" "Normal" $DUE_DATE;;
			[Ll]|"Low") save_tofile "$DATA_FILE" "$TEXT" "Low" $DUE_DATE;;
			*) echo -e ${red_text}"Invalid Priority!"${reset_attr}
				return ;;
		esac
	fi
}

# Save new todo to storage txt file
# 1st args filename
# 2nd args text
save_tofile()
{
	STARTTIME=`date '+%A %W %Y %X'`
	# Check if file exists
	if [ ! -f $1 ]; then
		# Create new file
		touch $1
		echo -e "$green_text$bold_text TODO Store file has created$red_text!$reset_attr -> $PWD/$1"
		echo -e "Adding new todo ${green_text}${blink_text}${bold_text}...${reset_attr}"
		# Get The last todo number
                last_line_num=`awk -F"#" '{ print $1}' $DATA_FILE | sort -n -r | sed -n '1p'`
                ((new_line=$last_line_num+1))
		echo -e "${new_line}#${2}#${STARTTIME}#${3}#${4}#" >> $1
	else
		#open text store
		#Get the last todo number
		last_line_num=`awk -F"#" '{ print $1 }' $DATA_FILE | sort -n -r | sed -n '1p'`
		((new_line=$last_line_num+1))
		echo -e "Adding new todo ${green_text}${blink_text}${bold_text}...${reset_attr}"
		echo -e "${new_line}#${2}#${STARTTIME}#${3}#${4}#" >> $1
	fi
}

# Show all todos
show_all()
{
	#AWK Color Codes
	RED='\033[01;31m'
	GREEN='\033[01;32m'
	YELLOW='\033[01;33m'
	BLUE='\033[01;34m'
	WHITE='\033[0m'
	MAGENTA='\033[35m'
	CYAN='\033[36m'
	BG_BLUE='\033[44m'
	BG_YELLOW='\033[93m'
	BG_GREEN='\033[92m'
	BG_RED='\033[91m'

	if [ ! -f "$DATA_FILE" ]; then
		echo -e "$red_text No Available Data"
		echo -e "$reset_attr To create a new$bold_text TODO$reset_attr by this ff command $blue_highlight./todo_cli.sh add \"your text\""$reset_attr
		exit 1
	else
		#Show TODO LIST HERE
            	echo -e $bold_text $green_text
            	echo -e "\t\t\t                       TODO LIST"
		echo -e "$reset_attr"
		echo -e "==========================================================================================================================="
		# FORMAT DATA in tabular form 
		awk -F"#" -v bgb=$BG_BLUE -v bgy=$BG_YELLOW -v bgg=$BG_GREEN -v bgr=$BG_RED -v c=$CYAN -v r=$RED -v m=$MAGENTA -v y=$YELLOW -v g=$GREEN -v b=$BLUE -v w=$WHITE '
			BEGIN { printf "%-3s %-50s %-15s %-22s %25s\n", "#", "TODO", "Due (hour)", "Date Created", "Priority" }

			#Change Color Based on Priority
			function check_prio(s){
				if (s == "High")
				return r s w
				if (s == "Normal")
				return b s w
				if (s == "Low")
				return y s w
			}
			#Filter by Date
			function filter_date(s){

			}

			{ printf "%s%-3s%s %-50s %s%-15s%s %s%-11s%s %30s\n",g,$1,w, $2, c,$5,w,m,$3,w, check_prio($4) }' $PWD"/"$DATA_FILE
		echo -e "\n"
	fi
}

# Delete todo
# 1st args todo number#
delete_todo()
{
	#chech if number is valid
	is_valid=`grep -i -e "$1#" $DATA_FILE | awk -F"#" '{ print $1 }' | wc -l` #1 is valid and 0 is not valid
	if [ -z "$1" ]; then
		echo "ID is missing. Please try again!"
		exit 1
	elif [ $is_valid -eq 0 ]; then
		echo "Number $1 does not exist"
		exit 1
	else
		#Delete todo by on the number
		sed -i /$1#/d $DATA_FILE
		echo -e ${green_text}"Number $1 was Deleted Successfully"${reset_attr}
	fi
}

# Edit todo
# 1st args todo number
# 2nd args modified text
modify_todo()
{
	is_valid=`grep -i -e "$1#" $DATA_FILE | awk -F"#" '{ print $1 }' | wc -l` #1 is valid and 0 is not valid
	if [ -z "$1" ]; then
		echo "ID number is missing."
		exit 1
	elif [ -z "$2" ]; then
		echo "Nothing has changed."
	elif [ $is_valid -eq 0 ]; then
	 	echo "Number $1 does not exist"
	 	exit 1
	else
		#Edit the todo
		#Get the ln
		old_text=`grep -i -e "$1#" $DATA_FILE | awk -F"#" '{ print $2 }'`
		old="$1#$old_text"
		new="$1#$2"
		sed -i "s/$old/$new/g" $DATA_FILE
		echo -e ${green_text}"Number $1 was successfully modified"${reset_attr}
	fi
}

#ChecK if valid package
valid_package()
{
	dpkg -s $1 &> /dev/null
	if [ $? -eq 0 ]; then
    		return 1 #Valid Package
	else
		sudo apt-get install $1
    		return 0
	fi
}

# END OF FUNCTIONS
# ----------------------------------------------------------------------------------------------------

# CLI Program Strats Here!!!!
# validate command args
started=0
if [ $# -eq 0 ]; then #OPEN MENU if NO ARGS
    while :
        do
		if [ $started -eq 0 ]; then
			echo -e $blue_text
			valid_package figlet
			if [ $? == 1 ]; then
				figlet Welcome TODO CLI
				((started++))
			fi
		else
			clear
		fi

	    echo -n -e $reset_attr
            echo -n -e $bold_text
            echo -e ""${green_text}"Created by Edison Villarta"$reset_attr"\n\n"
	    echo -e $bold_text"----------------------------------------------------------"
	    echo -e " Main Menu"
	    echo -e "----------------------------------------------------------"$reset_attr
            echo -e "$green_text[1]$white_text Add New"
            echo -e "$green_text[2]$white_text Show List"
            echo -e "$green_text[3]$white_text Delete "
            echo -e "$green_text[4]$white_text Modify"
            echo -e "$green_text[5]$white_text Exit/Stop"
            echo "======================="
            echo -e $reset_attr
            echo -n "Enter your menu choice [1-5] : "; read CHOICE
            case $CHOICE in
                1)
			echo -n "New todo : "; read text
			echo -n -e "Priority ${red_highlight}[High]${blue_highlight}[Normal]${yellow_highlight}[Low]${reset_attr}: "; read priority
			echo -n -e "Due Date in hours [1-24]: "; read due_date
			new_todo "$text" $priority $due_date #validate todo
			echo "Press a key ..."; read -n 1;;
                2) 	show_all
			echo "Press a key ..."; read -n 1;;
                3)	show_all
			echo -e ${red_highlight}"Delete TODO"${reset_attr}
			echo -n "Enter the number: "; read num
			delete_todo $num
			echo "Press a key ..."; read -n 1;;
                4)	show_all
			echo -e ${yellow_highlight}"Modify TODO"${reset_attr}
			echo -n "Enter the number: "; read num1
			echo -n "Ente the new todo: "; read text1
			modify_todo $num1 "$text1"
			echo "Press a key ..."; read -n 1;;
                5)
			echo -e "${red_text}Terminating the program ... ${reset_attr}" "Bye!"; exit 0 ;;
                *)
			echo "Opps!!! Please select choice 1,2,3,4, or 5";
                    	echo -n "Press a key. . ." ; read ;;
            esac
    done
else
    #excute read args
        case $1 in
            "add") new_todo "$2" $3 $4;;
            "modify") modify_todo $2 "$3";;
            "delete") delete_todo $2;;
            "list") show_all ;;
            *) echo "Invalid todo action"; exit 1;;
        esac
fi
