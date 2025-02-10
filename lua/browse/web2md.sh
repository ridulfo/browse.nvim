set -e  # Exit on error

# Creates a temporary file, this is necessary for pandoc to convert the links
# from relative to absolute. It will be removed at the end of the script.
TEMP_FILE=$(mktemp)

# Define a cleanup function to delete the temporary file
cleanup() {
  rm -f "$TEMP_FILE"
}

# Register the cleanup function to be called on script exit
trap cleanup EXIT

# Download the content with link conversion quietly
wget -q -k --convert-links -O "$TEMP_FILE" "$1"

# Process the content with pandoc and grep, then print the output
cat "$TEMP_FILE" | pandoc -f html -t gfm-raw_html | grep -v '\bdata:image/svg+xml\b'
