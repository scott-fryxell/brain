#!/bin/bash

#!/usr/bin/env bash
echo "howdy"
# Check if a filename was provided
if [ $# -eq 0 ]; then
  echo "Please provide a filename as an argument."
  exit 1
fi

# Set the input file
input_file="$1"

# Check if the input file exists
if [ ! -f "$input_file" ]; then
  echo "File not found: $input_file"
  exit 1
fi

# Create a temporary file
temp_file=$(mktemp)

# Add a marker to the beginning of each section
sed 's/^# /\n###SECTION###/' "$input_file" >"$temp_file"

# Use awk to process the file and create separate files
awk '
BEGIN { RS="###SECTION###\n"; FS="\n"; ORS="\n" }
NR > 1 {
    # Extract the date from the first line
    split($1, date_parts, ", ")
    # Create a filename using the date (replace spaces with underscores)
    filename = gensub(/[^a-zA-Z0-9]/, "_", "g", date_parts[2]) ".md"
    # Write the content to the file
    print > filename
}
' "$temp_file"

# Remove the temporary file
rm "$temp_file"

echo "Files have been created for each date section."
