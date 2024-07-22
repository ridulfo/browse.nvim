set -e  # Exit on error
URL="$1"
TEMP_FILE=$(mktemp)  # Creates a temporary file

# Download the content with link conversion quietly
wget -q -k --convert-links -O "$TEMP_FILE" "$URL"

# Process the content with pandoc and grep, then print the output
cat "$TEMP_FILE" | pandoc -f html -t gfm-raw_html | grep -v '\bdata:image/svg+xml\b'

# Remove the temporary file
rm "$TEMP_FILE"
