#! /usr/bin/env bash

# change to the project folder and extract the folder path
cd "$(dirname "${BASH_SOURCE[0]}")"

# set the pipefail

set -oue pipefail

# set the url 

export DATA_SOURCE_URL="${DATA_SOURCE_URL:-"https://www.stats.govt.nz/assets/Uploads/Annual-enterprise-survey/Annual-enterprise-survey-2023-financial-year-provisional/Download-data/annual-enterprise-survey-2023-financial-year-provisional.csv"}"


# set variables for directory 

RAW_DIR="raw"
TRANSFORMED_DIR="Transformed"
GOLD_DIR="Gold"

RAW_FILE="${RAW_DIR}/annual_survey.csv"
TRANSFORMED_FILE="${TRANSFORMED_DIR}/2023_annual_survey.csv"
GOLD_FILE="${GOLD_DIR}/2023_annual_survey.csv"

# HELPER FUNCTIONS

log_information() {
    echo -e "[INFO] `date` - $1"
}

log_error() {
    echo -e "[ERROR] `date` - $1" >&2
}

# function to check if file exist in a directory
check_file_exists() {
    local file_path="$1"
local stage_name="$2"

    if [[ -f "${file_path}" && -s "${file_path}" ]]; then
        log_information "SUCCESS: File successfully created and non empty file in '${file_path}' ${stage_name} stage."
    else
        log_error "FAILED: File missing or empty at '${file_path}' during ${stage_name} stage."
        exit 1
    fi
}



# ETL PROCESS

log_information "======== STARTING ETL PROCESS ============"
log_information "[STEP 1/3] Starting EXTRACT stage..."

# make the directory if it doesn't exist
mkdir -p "${RAW_DIR}"

log_information "Dowloading raw CSV dataset from URL: ${DATA_SOURCE_URL}"

if command -v wget &> /dev/null ; then
    wget -q "${DATA_SOURCE_URL}" -O "${RAW_FILE}"
elif command -v curl &> /dev/null; then
    curl -sSL "${DATA_SOURCE_URL}" -o "${RAW_FILE}"
else
    log_error "None of 'wget' and 'curl' is available on this system."
    exit 1
fi

# confirm file extraction
check_file_exists "${RAW_FILE}" "Extract"

#===========================================================

# TRANSFORM STAGE

log_information "[STEP 2/3] Starting TRANSFORM stage..."

# make directory if not exists

mkdir -p "${TRANSFORMED_DIR}"

log_information "Transforming headers, changing Variable_code to variable_code and selecting target columns (year, Value, Units, Variable_code)..."

# Replace the column header name and select the needed columns
sed "s/Variable_code/variable_code/" "${RAW_FILE}" | cut -d',' -f 1,5,6,9 > "${TRANSFORMED_FILE}"

check_file_exists "${TRANSFORMED_FILE}" "Transform"

# STAGE 3: LOAD

log_information "[STEP 3/3] Starting LOAD stage..."

# Create Gold directory if it doesn't exist
mkdir -p "${GOLD_DIR}"

log_information "Loading transformed data into Gold storage directory..."
cp "${TRANSFORMED_FILE}" "${GOLD_FILE}"

# Confirm file load into Gold directory
check_file_exists "${GOLD_FILE}" "Load"

log_information  "======== ETL PROCESS COMPLETED SUCCESSFULLY ============"





