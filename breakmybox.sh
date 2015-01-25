#!/bin/sh
 
#######################################
#                                     #
#  https://github.com/pedroguima      #
#                                     #
#######################################

function spinner {
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
	echo -e "\n##################### breakmybox (please!) #####################"
}

function moreinfo {
	echo -e "\nTry 'breakmybox.sh help' for more information\n"
}

function usage {
	echo -e "\nbreakmybox.sh [problem] [options]"
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
	echo "\nAn error has occured. Please check and try again.\n"
	exit 1
}

function help {
	header
	usage
	echo -e "\nFile system problems:"
	echo -e "\n\t\"tmf\" \"directory\" - [ Too Many Files ]
		- Fills a partition with dummy small files until it runs out of inodes"	
	echo -e "\n\t\"ldf\" \"size in MB\" - [ Large Deleted File ]
		- Creates a big file, opens it and then deletes the inode, keeping space occupied"	
	echo -e "\nNetwork problems:"
	echo -e "\nSystem problems:"
	echo -e "\nFunny problems:"
	echo -e "\n\t\"chmod\" - [chmod -x chmod]
		-  Remove execute permissions of $(which chmod)
		"
	## remove file beginning with "-" ex.: -file
	## remove path 
}

function tmf {
	local dir=$1
	header
	
	if [ ! -n "$dir" -o ! -d "$dir" ]; then
		echo "Please provide a valid directory"
		exit 1
	fi	
	echo -en "\nAbout to create a lot of files in $dir. Are you sure? (y/n) "
	read -n 2 reply	
	
	if [[ ! $reply =~ ^[Yy]$ ]]; then
		echo "Leaving..."
		exit 0
	fi 
	spinner "Filling up $dir with dummy files. Please wait..." &
	spinner_pid=$!
	trap "kill -9 $spinner_pid $BASHPID" SIGHUP SIGINT SIGTERM SIGKILL
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
	local size= $1
}

function chmdfun {
	options="Yes No"	
	chmod_path=$(which chmod)
	
	PS3="Option: "
	echo "Remove execute permissions from $chmod_path ?"
	select option in $options; do
		echo "hello"
	done

	$chmod_path -x $chmod_path 
	if [ $? -eq 0 ]; then
		success
	else
		error
	fi
}

problem=$1

case "$problem" in
	"help" )
		help ;;
	"tmf" )
		tmf $2 ;;
	"ldf" )
		ldf $2 ;;
	"chmod" )
		chmdfun ;;
	* )
		usage
		moreinfo ;;
esac

exit 0
