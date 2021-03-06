#!/bin/sh
 
#######################################
#                                     #
#  https://github.com/pedroguima      #
#                                     #
#######################################



function spinner  {
	local delay=0.5
	local msg=$1
	local spinstr='|/-\'
	echo -e "\n$msg "
	while [ true ]; do
		local temp=${spinstr#?}
		printf "[%c] " "$spinstr"
		local spinstr=$temp${spinstr%"$temp"}
		sleep $delay
		printf "\b\b\b\b\b\b"
	done
	printf "    \b\b\b\b"
}

function header {
	echo -e "\n##################### Break My Box. Simple and neat! #####################"
}

function moreinfo {
	echo -e "\nTry 'breakmybox.sh help' for more information\n"
}

function usage {
	echo -e "\nbreakmybox.sh problem [options]"
}

function random_string {
	local size=$1
	cat /dev/urandom | tr -dc '0-9a-zA-Z_-' | head -c $size
}

function success {
	echo -e "\n\nDone!\n"
	exit 0
}

function error {
	local msg=$1
	if [ -n "$msg" ]; then
		echo -e "\n$msg \n"
	else
		echo -e "\nAn error as occured. Please check."
	fi
	exit 1
}

function helpme {
	header
	usage
	echo -e "\nOS problems:"
	echo -e "\n\t\"nomorepids\"
		- Decreases drastically the number of available PIDs leaving the box unable to create further processes."	
	echo -e "\nFile system problems:"
	echo -e "\n\t\"tmf\" \"directory\"
		- Too many files - Fills a partition with temporary files until it runs out of inodes"	
	echo -e "\n\t\"ldf\" \"size in MB\" \"directory\"
		- Large deleted file - Creates a deleted open file"	
	echo -e "\nFunny problems:"
	echo -e "\n\t\"chmod\" - [chmod -x chmod]
		-  Remove execute permissions of $(which chmod)
		"
}


function tmf {
	local dir=$1
	header
	
	if [ ! -n "$dir" -o ! -d "$dir" ]; then
		error "Please provide a valid directory."
	fi	

	echo -en "\nAbout to create a lot of files in $dir. Are you sure? (y/n) "
	read -n 2 reply	
	
	if [[ ! $reply =~ ^[Yy]$ ]]; then
		echo "Leaving..."
		exit 0
	fi 
	spinner "Filling up $dir with dummy files. Please wait..." &
	spinner_pid=$!
	trap "kill -9 $spinner_pid $BASHPID" SIGHUP SIGINT SIGTERM SIGQUIT
	while [ true ]; do
		mktemp -q -p $dir > /dev/null
		if [ $? -ne 0 ]; then
			kill $spinner_pid	
			success
		fi
	done
	kill $spinner_pid	
	error
}

function ldf {
	header
	local size=$1
	local dir=$2
	local filename="naughty_file.log"
	local naughtypath=$dir/$filename
	
	if [[ ! $size =~ ^[0-9]+$ ]]; then
		error "Please provide a valid size."
	fi

	if [ ! -n "$dir" -o ! -d "$dir" ]; then
		error "Please provide a valid directory."
	fi	

	echo -ne "\n\nCreate a $size MB deleted file in $naughtypath? (y/n) "
	read -n 2 reply	
	
	if [[ ! $reply =~ ^[Yy]$ ]]; then
		echo "Leaving..."
		exit 0
	fi 

	dd if=/dev/zero of=$naughtypath bs=1M count=$size &> /dev/null

	tail -F $naughtypath &> /dev/null & 
	echo -en "PID locking file: $!\n\n"
	rm -f $naughtypath
}

function chmdfun {
	header
	chmod_path=$(which chmod)
	
	echo -ne "\nRemove execute permissions from $chmod_path? (y/n) "
	read -n 2 reply	
	
	if [[ ! $reply =~ ^[Yy]$ ]]; then
		echo "Leaving..."
		exit 0
	fi 

	$chmod_path -x $chmod_path 
	if [ $? -eq 0 ]; then
		success
	else
		error
	fi
}

function nomorepids {
	local pid_max="/proc/sys/kernel/pid_max"
	local lower_pid="301"
	local res=0
	header
	echo -e "\nThe current value of \"$pid_max\" is $(cat $pid_max)"
	echo -ne "Set the value to $lower_pid? (y/n) "
	read -n 2 reply	

        if [[ ! $reply =~ ^[Yy]$ ]]; then
                echo "Leaving..."
                exit 0
        fi

	echo $lower_pid > $pid_max
	
	while [ $res -eq 0 ]; do
		tail -f /dev/null & disown	
	done
}

problem=$1

case "$problem" in
	"help" )
		helpme ;;
	"tmf" )
		tmf $2 ;;
	"ldf" )
		ldf $2 $3 ;;
	"chmod" )
		chmdfun ;;
	"nomorepids" )
		nomorepids ;;
	* )
		usage
		moreinfo ;;
esac

exit 0
