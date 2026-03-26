#! /usr/bin/env bash

#- The tool should compress the logs in a tar.gz file and store them in a new directory.
#- The tool should log the date and time of the archive to a file.
function archive() {
	: "${1?Error: Argument 1 is required}"
		#echo "Missing directory"

	local dir=$1
	local log_history="archive_history.txt"

	if [ -d "$dir" ] && ls "$dir"/*.log >/dev/null 2>&1; then

		file_ts=$(date +'%Y%m%d_%H%M%S')
		archive_dir="log_archive"
		if [ ! -d $archive_dir ]; then
			echo "Creating directory for logs archive"
			echo "$archive_dir" created.
			mkdir $archive_dir
		fi

		archive_tar="$archive_dir/$(basename $dir)_archive_$file_ts.tar.gz"
		echo "$archive_tar"
		echo "Compressing $dir ===> $archive_tar"
		sudo tar -a -cf $archive_tar $dir > /dev/null 2>&1
		echo "Archive created: $archive_tar at $now" >> "$archive_dir/$log_history"
		echo "Compression completed. History updated in $log_history." 
	else
		echo "Error: Directory not found or contains no .log files."
	fi

}

archive $1