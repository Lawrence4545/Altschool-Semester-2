#!/bin/bash

# Function to list directory contents and sort based on the argument
list_and_sort_directory() {

  local dir="$1"
  local sort_order="$2"

  echo "Listing contents of $dir:"

  if [ "$sort_order" = "a" ]; then
    ls -1 "$dir"

  elif [ "$sort_order" = "d" ]; then
    ls -1 -r "$dir"

  else
    echo "Invalid sort order argument: $sort_order. Please use 'a' or 'd'."

  fi
}

# Check if there are no arguments

if [ "$#" -eq 0 ]; then
  echo "Usage: $1 directory_path [a|d] [directory_path [a|d] ...]"
  exit 1

fi

# Loop through the arguments two at a time (directory and sort order)

while [ "$#" -ge 2 ];

do
  dir="$1"

  sort_order="$2"

  list_and_sort_directory "$dir" "$sort_order"
  shift 2

done

