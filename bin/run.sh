#!/usr/bin/env bash

# Synopsis:
# Run the test runner on a solution.

# Arguments:
# $1: exercise slug
# $2: absolute path to solution folder
# $3: absolute path to output directory

# Output:
# Writes the test results to a results.json file in the passed-in output directory.
# The test results are formatted according to the specifications at https://github.com/exercism/docs/blob/main/building/tooling/test-runners/interface.md

# Example:
# ./bin/run.sh two-fer /absolute/path/to/two-fer/solution/folder/ /absolute/path/to/output/directory/

# If any required arguments is missing, print the usage and exit
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo "usage: ./bin/run.sh exercise-slug /absolute/path/to/two-fer/solution/folder/ /absolute/path/to/output/directory/"
    exit 1
fi

SLUG="$1"
INPUT_DIR="${2%/}"
OUTPUT_DIR="${3%/}"

if [[ "${RUN_IN_DOCKER}" == "TRUE" ]]; then  
    WORKING_DIR="${PWD}"

    # 1. Modify Package.swift to add new dependencies
    # 2. Copy source and destination files
    cp -r "${INPUT_DIR}/.meta" "${WORKING_DIR}"

    find "${WORKING_DIR}/Sources/WarmUp" -type f -delete
    find "${WORKING_DIR}/Tests/WarmUpTests" -type f -delete

    find "${INPUT_DIR}/Sources" -name '*.swift' -exec cp {} "${WORKING_DIR}/Sources/WarmUp/" \;
    find "${INPUT_DIR}/Tests" -name '*.swift' -exec cp {} "${WORKING_DIR}/Tests/WarmUpTests/" \;

    ls -al "${WORKING_DIR}/Tests/WarmUpTests/"

    filename=$(jq -r '.files.test[0] | split("/") | last' ${INPUT_DIR}/.meta/config.json)
    destination_path="/Tests/WarmUpTests/${filename}"
    jq --arg fname "$destination_path" '.files.test[0] = $fname' ${INPUT_DIR}/.meta/config.json > tmp.json && mv tmp.json ${WORKING_DIR}/.meta/config.json

    sed -i 's/@testable import [^ ]\+/@testable import WarmUp/g' "${WORKING_DIR}/Tests/WarmUpTests"/*.swift
else
    WORKING_DIR=${INPUT_DIR}
fi

junit_file="${WORKING_DIR}/results-swift-testing.xml"
spec_file="${WORKING_DIR}/$(jq -r '.files.test[0]' ${WORKING_DIR}/.meta/config.json)"
capture_file="${OUTPUT_DIR}/capture"
results_file="${OUTPUT_DIR}/results.json"

touch "${results_file}"

export RUNALL=true
swift test \
    --package-path "${WORKING_DIR}" \
    --xunit-output "${WORKING_DIR}/results.xml" \
    --skip-update &> "${capture_file}"

./bin/TestRunner "${spec_file}" "${junit_file}" "${capture_file}" "${results_file}" "${SLUG}"
