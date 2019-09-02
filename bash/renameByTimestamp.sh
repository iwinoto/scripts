files=$1

for file in $files; do
	echo 'file: '"$file"
	# get the last modified time stamp of the file
	# use sed to convert the time stamp to YYYYMMDDHHMMSS and set to $timeStamp
	timestamp=`stat -c %y "$file" | sed 's/[ :-]//g'`
	timestamp=${timestamp:0:14}
	echo 'new timestamp: '"$timestamp"
	# get the file path
	fullPath=$(readlink -f "$file")
	echo 'full file: '"$fullPath"
	# get the file without path
	filename=$(basename "$file")
	echo 'filename: '"$filename"
	# get directory
	dir=$(dirname "$file")
	echo 'directory: '"$dir"
	# get the file extension
	extension="${filename##*.}"
	longExtension=`echo "$file" | cut -d'.' -f2-`
	echo 'extension: '"$extension"	
	echo 'longExtension: '"$longExtension"
	# set the new file name
	newFileName="$dir/$timestamp.$longExtension"
	echo 'new full file name: '"$newFileName"
	while [ -f "$newFileName" ]
	do
		echo "$newFileName"' already exists.'
		newFileName="$dir/$timestamp-$RANDOM.$longExtension"
		echo 'Renaming to '"$newFileName"
	done
	# rename the file.
	mv "$file" "$newFileName"
done

