#!/bin/bash

# Check if lipo is available
if ! command -v lipo &> /dev/null; then
    echo "Error: lipo command not found. This script requires Xcode Command Line Tools."
    exit 1
fi

# Function to process a single file
process_file() {
    local file="$1"
    
    # Check if file is a Mach-O binary
    if file "$file" | grep -q "Mach-O universal binary"; then
        echo "Processing: $file"
        
        # Check if file contains both architectures
        if lipo -info "$file" | grep -q "x86_64"; then
            # Create temporary file
            temp_file="${file}.arm64"
            
            # Extract arm64 architecture
            if lipo "$file" -thin arm64 -output "$temp_file" 2>/dev/null; then
                # Replace original with arm64 version
                mv "$temp_file" "$file"
                chmod --reference="$file" "$temp_file" 2>/dev/null
                echo "✓ Removed Intel architecture from: $file"
            else
                echo "⨯ Failed to process: $file"
                rm -f "$temp_file"
            fi
        fi
    fi
}

# Main script
main() {
    local target_dir="${1:-.}"
    
    if [ ! -d "$target_dir" ]; then
        echo "Error: Directory '$target_dir' not found."
        exit 1
    fi
    
    echo "Starting universal binary processing in: $target_dir"
    echo "This will remove x86_64 architecture and keep only arm64..."
    echo
    
    # Find and process all files recursively
    find "$target_dir" -type f -not -path "*/\.*" | while read -r file; do
        process_file "$file"
    done
    
    echo
    echo "Processing complete!"
}

# Run the script with the provided directory or current directory
main "$@"
