# breakmybox
## Break your box. Simple! ##

"Break My Box" aims to be a helpful tool on testing system administrator skills on various issues (some weirder than others).

Feel free to add or suggest your own issues.



At the moment, the script can trigger the following issues:

	- tmf (too many files) - Fills a partition with temporary small files until the filesystem runs out of inodes;
	- ldf (large deleted file) - Creates a file with a specified size and then deletes so the space is kept in use until the process reading it is killed;
	- chmod - Remove execute permissions from chmod, creating a paradox.	


