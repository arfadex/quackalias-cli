#!/bin/bash

API_KEY="YOUR_API_KEY_HERE"
HISTORY_PATH="$HOME/.local/share/ddg"
LOG_FILE="$HISTORY_PATH/aliases_history.txt"

# Ensure the history directory exists
mkdir -p "$HISTORY_PATH"

generate_alias() {
    RESPONSE=$(curl -s -X POST \
        -H "Authorization: Bearer $API_KEY" \
        -H "Content-Type: application/json" \
        -d '{}' \
        https://quack.duckduckgo.com/api/email/addresses)

    ALIAS=$(echo "$RESPONSE" | grep -oP '(?<="address":")[^"]*')
    if [ -n "$ALIAS" ]; then
        FULL_ALIAS="$ALIAS@duck.com"
        TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
        echo "$TIMESTAMP - $FULL_ALIAS" >> "$LOG_FILE"
        echo "Email alias generated: $FULL_ALIAS"
    else
        echo "Failed to generate alias. Response: $RESPONSE"
    fi
}

show_history() {
    if [ -f "$LOG_FILE" ]; then
        cat "$LOG_FILE"
    else
        echo "No aliases history found."
    fi
}

show_menu() {
    echo "Please choose an option:"
    echo "1 - Generate email alias"
    echo "2 - Show aliases history"

    read -p "Enter your choice (1 or 2): " choice
    case $choice in
        1)
            generate_alias
            ;;
        2)
            show_history
            ;;
        *)
            echo "Invalid choice. Please run the script again and select a valid option."
            ;;
    esac
}

if [ -n "$1" ]; then
    case $1 in
        generate)
            generate_alias
            ;;
        history)
            show_history
            ;;
        *)
            echo "Usage: $0 [generate|history]"
            ;;
    esac
else
    show_menu
fi