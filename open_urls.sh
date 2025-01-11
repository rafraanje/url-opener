#!/bin/bash

show_gui=false
grab_selection=false
input=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --gui)
            show_gui=true
            shift
            ;;
        --grab)
            grab_selection=true
            shift
            ;;
        *)
            input="$1"
            shift
            ;;
    esac
done

config_file="$(dirname "$0")/url_patterns.conf"

if [ ! -f "$config_file" ]; then
    echo "Error: Configuration file not found: $config_file"
    exit 1
fi

# Grab selected text if requested
if [ "$grab_selection" = true ]; then
    # Check if xclip is installed
    if ! command -v xclip &> /dev/null; then
        echo "Error: xclip is not installed. Please install it first:"
        echo "sudo apt-get install xclip  # For Debian/Ubuntu"
        echo "sudo yum install xclip      # For RedHat/CentOS"
        exit 1
    fi

    # Try to grab the selection
    grabbed_text=$(xclip -o -selection primary 2>/dev/null || xclip -o -selection clipboard 2>/dev/null)
    
    if [ -n "$grabbed_text" ]; then
        input="$grabbed_text"
    else
        echo "Error: No text selected"
        exit 1
    fi
fi

# Show GUI if requested
if [ "$show_gui" = true ]; then
    # Check if zenity is installed
    if ! command -v zenity &> /dev/null; then
        echo "Error: zenity is not installed. Please install it first:"
        echo "sudo apt-get install zenity  # For Debian/Ubuntu"
        echo "sudo yum install zenity      # For RedHat/CentOS"
        exit 1
    fi

    # Show GUI prompt with pre-filled text if input was provided
    result=$(zenity --entry \
        --title="Open URL" \
        --text="Enter identifier (e.g., PROJECT-1234):" \
        --entry-text="${input}" \
        --width=300)
    
    # Check if user clicked Cancel
    if [ $? -ne 0 ]; then
        exit 0
    fi
    
    input="$result"
fi

# Validate that we have input
if [ -z "$input" ]; then
    echo "Usage: $0 [--gui] [--grab] <identifier>"
    echo "Example: $0 PROJECT-1234"
    echo "         $0 --gui"
    echo "         $0 --grab"
    echo "         $0 --gui --grab"
    exit 1
fi

# Read the config file and process each pattern
matched=false
while IFS= read -r line || [ -n "$line" ]; do
    # Skip empty lines and comments
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    
    # Split the line into pattern and url_template
    pattern=$(echo "$line" | cut -d'|' -f1)
    url_template=$(echo "$line" | cut -d'|' -f2)
    
    # Check if input matches the pattern
    if [[ "$input" =~ $pattern ]]; then
        matched=true
        # Replace {match} with the full match
        url="${url_template/\{match\}/$input}"
        
        # Replace {group1}, {group2}, etc. with captured groups
        for i in "${!BASH_REMATCH[@]}"; do
            if [ $i -gt 0 ]; then
                url="${url/\{group$i\}/${BASH_REMATCH[$i]}}"
            fi
        done
        
        if [ "$show_gui" = true ]; then
            : # Do nothing in GUI mode
        else
            echo "Opening: $url"
        fi
        
        xdg-open "$url" 2>/dev/null || open "$url" 2>/dev/null || {
            [ "$show_gui" = true ] && zenity --error --text="Could not open URL: $url" --width=300
            echo "Error: Could not open URL"
        }
    fi
done < "$config_file"

if [ "$matched" = false ]; then
    if [ "$show_gui" = true ]; then
        zenity --error --text="No matching URL pattern found for: $input" --width=300
    else
        echo "No matching URL pattern found for: $input"
    fi
    exit 1
fi 