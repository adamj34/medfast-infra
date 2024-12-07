#!/bin/bash

set -euo pipefail

# Check if parameter is provided
if [ $# -eq 0 ]; then
    echo "Error: No tfvars filename provided"
    echo "Usage: $0 <tfvars_filename>"
    exit 1
fi

echo "Generating tfvars file from TF_VAR_ variables"
TFVARS_FILE="${SYSTEM_DEFAULT_WORKINGDIRECTORY}/$1"
touch "$TFVARS_FILE"
for var in $(printenv | grep '^TF_VAR_' | cut -d= -f1); do
    key=${var#TF_VAR_}  # Removes "TF_VAR_" prefix
    key=$(echo "$key" | tr '[:upper:]' '[:lower:]')  # Convert to lowercase
    value=${!var}
    echo "${key} = \"${value}\"" >> "$TFVARS_FILE"
done

cat "$TFVARS_FILE"