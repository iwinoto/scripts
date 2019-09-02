#!/bin/bash

SELECTOR="*.*"
DATE_REGEX_SELECTOR="([0-9]{8}[_-]?[0-9]{6})"
DATE_REGEX="([0-9]{4})([0-9]{2})([0-9]{2})([0-9]{2})[-_]?([0-9]{2})([0-9]{2})"

print_help()
{
  echo
  echo "$0"
  echo "Set file create, modified and opened times from time embedded in filename."
  echo "When image files from camera devices are copied to another location,"
  echo "the filesystem will set the timestamp to the time the file was copied."
  echo "Use this script to extract the camera time from the filename and reset"
  echo "the file timestamp."
  echo "Scripts looks in the filename for a regex of '$DATE_REGEX'"
  echo
  echo "Usage:"
  echo "$0 [ -h] DIR"
  echo
  echo "Arguments:"
  echo "DIR  Directory specifier. All files in this directory satisfying"
  echo "     the selector (-s) option will be searched for an embedded"
  echo "     timestamp."
  echo
  echo "Options are:"
  echo "-h  Print this message."
  echo
  exit 0
}

while getopts "s:h" optname
do
    case "$optname" in
      "s")
        SELECTOR=$OPTARG
        ;;
      "h")
        print_help
        exit $?
        ;;
      "?")
        echo "Unknown option $OPTARG"
        print_help
        exit $?
        ;;
      ":")
        echo "No argument value for option $OPTARG"
        print_help
        exit $?
        ;;
      *)
      # Should not occur
        echo "Unknown error while processing options"
        print_help
        exit $?
        ;;
    esac
done

shift $((OPTIND -1))

if [ -n "$1" ]; then
  DIR="$1"
else
  echo "Incorrect number of arguments."
  echo "You must provide a directory."
  print_help
  exit 1
fi

for f in "$DIR"/$SELECTOR
do
  echo $f
  if [[ "$f" =~ .*([0-9]{8}[_-]?[0-9]{6}).* ]]; then
    unparsed="${BASH_REMATCH[1]}"
    echo "match: $unparsed"
    if [[ "$unparsed" =~ ([0-9]{4})([0-9]{2})([0-9]{2})([0-9]{2})[-_]?([0-9]{2})([0-9]{2}) ]]; then
      year="${BASH_REMATCH[1]}"
      month="${BASH_REMATCH[2]}"
      day="${BASH_REMATCH[3]}"
      hour="${BASH_REMATCH[4]}"
      min="${BASH_REMATCH[5]}"
      sec="${BASH_REMATCH[6]}"
      timestr="$year-$month-$day $hour:$min:$sec"
      echo "timestamp: $timestr"
      touch -c -d "$timestr" "$f"
    fi
  fi
done

echo we are done
