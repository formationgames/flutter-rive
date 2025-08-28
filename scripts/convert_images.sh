#!/bin/bash

# Convert all images in the given directory to webp format
# using cwebp (https://developers.google.com/speed/webp/docs/cwebp)
# Input can be a single file or a directory.

# Command line arguments:
# -q: Quality (default 80)
# -f: Force overwrite (default false)
# -v: Verbose output (default false)
# -i: Input, file or directory (required)
# -o: Output directory (required)

# Example Usage:
# ./scripts/convert_images.sh -q 90 -i ~/input -o ~/output -v -f

# Default values
quality=80
force=false
verbose=false
input_dir=""
output_dir=""

# Parse command line arguments
while getopts "q:w:s:fvi:o:" opt; do
  case $opt in
    q) quality=$OPTARG ;;
    f) force=true ;;
    v) verbose=true ;;
    i) input_dir=$OPTARG ;;
    o) output_dir=$OPTARG ;;
    *) echo "Invalid option: -$OPTARG" >&2
       exit 1 ;;
  esac
done

# Check for required input and output directories
if [[ -z $input_dir ]] || [[ -z $output_dir ]]; then
  echo "Input and output directories are required."
  echo "Usage: $0 -q [quality] -f -v -i [input_dir] -o [output_dir]"
  exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$output_dir"

# Function to convert image to webp
convert_to_webp() {
  local input_file=$1
  local output_file=$2
  if [[ $force = true ]] || [[ ! -f $output_file ]]; then
    if [[ $verbose = true ]]; then
      cwebp -q $quality "$input_file" -o "$output_file"
    else
      cwebp -q $quality "$input_file" -o "$output_file" > /dev/null 2>&1
    fi
  else
    echo "Skipping $input_file as the WEBP output already exists. Use -f to force overwrite."
  fi
}

# Process all PNG files in directory
if [[ -d $input_dir ]]; then
  rm -f "$output_dir/manifest.txt"
  for file in "$input_dir"/*.png; do
    if [[ -f $file ]]; then
      filename=$(basename "${file%.*}")
      echo "Converting $filename"
      output_file="$output_dir/$filename"
      convert_to_webp "$file" "$output_file"
    fi
  done
elif [[ -f $input_dir ]]; then
  # Process single file
  if [[ ${input_dir: -4} == ".png" ]]; then
    output_file="$output_dir/$(basename "${input_dir%.*}").webp"
    convert_to_webp "$input_dir" "$output_file"
  else
    echo "Input is not a PNG file."
  fi
else
  echo "Invalid input. Please specify a directory containing PNG files."
  exit 1
fi