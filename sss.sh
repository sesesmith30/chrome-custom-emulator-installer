#!/bin/bash



# Function to install jq via Homebrew on macOS
install_jq_mac() {
    echo "jq is not installed. Installing via Homebrew..."
    brew install jq
}

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    # Check if the system is macOS
    if [[ $(uname) == "Darwin" ]]; then
        # Install jq via Homebrew
        install_jq_mac
    else
        echo "jq is not installed and the system is not macOS. Please install jq manually."
        exit 1
    fi
fi

file_path=~/Library/Application\ Support/Google/Chrome/Default/Preferences
existing_json=$(<"$file_path")


while IFS= read -r line; do

    if [[ "$line" != "[" && "$line" != "]" ]]; then

      line=$(echo "$line" | sed 's/},$/}/')
      parsed_json=$(jq '.devtools.preferences.customEmulatedDeviceList |= fromjson' <<< "$existing_json")
      updated_json=$(jq --argjson line "$line" '.devtools.preferences.customEmulatedDeviceList += [$line]' <<< $parsed_json)
      final_json=$(jq -c '.devtools.preferences.customEmulatedDeviceList |= tostring' <<< "$parsed_json")
      jq -c '.devtools.preferences.customEmulatedDeviceList |= tostring' <<< "$updated_json" > "$file_path"
      
      echo "Done with  <------  $(jq '.title' <<< "$line")"

    fi
done < "devices.json"



