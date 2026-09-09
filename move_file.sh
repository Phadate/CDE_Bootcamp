#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Default to current directory if no directory argument is passed
SOURCE_DIR="${1:-.}"
TARGET_DIR="${SOURCE_DIR}/json_and_CSV"

# Create destination directory if it does not exist
mkdir -p "${TARGET_DIR}"


# Collect all matching regular files
files=()
for file in "${SOURCE_DIR}"/*.csv "${SOURCE_DIR}"/*.json; do
    if [[ -f "${file}" ]]; then
        files+=("${file}")
    fi
done

# Verify if any matching files exist
if (( ${#files[@]} == 0 )); then
    echo "No CSV or JSON files found in '${SOURCE_DIR}'."
    exit 0
fi

# Move matching files into the target folder
echo "Moving ${#files[@]} file(s) to '${TARGET_DIR}'..."
for file in "${files[@]}"; do
    # -v provide additional comment
    mv -v "${file}" "${TARGET_DIR}/"
done

echo "File transfer completed successfully."
