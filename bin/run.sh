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
    # Docker image contains a prebuilt package called TestEnvironment with a ready .build directory 
    # to build solutions as fast as it possible. To minimize changes in the build graph,
    # exercise resources are copied inside the TestEnvironment package as if they had always been there.

    WORKING_DIR="${PWD}"
    desc_file="${WORKING_DIR}/package_desc.json"
    swift package dump-package --package-path ${INPUT_DIR} > "$desc_file"

    # 1. Replace source files with those of an exercise
    find "${WORKING_DIR}/Sources/TestEnvironment" -type f -delete
    target_name=$(jq -r '.targets[] | select(.type=="regular") | .name' "$desc_file" | head -1)
    cp -rf "${INPUT_DIR}/Sources/${target_name}/." "${WORKING_DIR}/Sources/TestEnvironment/"

    find "${WORKING_DIR}/Tests/TestEnvironmentTests" -type f -delete
    test_target_name=$(jq -r '.targets[] | select(.type=="test") | .name' "$desc_file" | head -1)
    cp -rf "${INPUT_DIR}/Tests/${test_target_name}/." "${WORKING_DIR}/Tests/TestEnvironmentTests/"

    # 2. Replace @testable import SomeModule with @testable import TestEnvironment
    sed -i 's/@testable import [^ ]\+/@testable import TestEnvironment/g' "${WORKING_DIR}/Tests/TestEnvironmentTests"/*.swift

    # 3. Copy and modify Package.swift
    cp "${INPUT_DIR}/Package.swift" "${WORKING_DIR}"
    sed -i "s/${target_name}/TestEnvironment/g" "${WORKING_DIR}/Package.swift"

else
    WORKING_DIR=${INPUT_DIR}
fi

junit_file="${WORKING_DIR}/results-swift-testing.xml"
spec_file="${INPUT_DIR}/$(jq -r '.files.test[0]' ${INPUT_DIR}/.meta/config.json)"
capture_file="${OUTPUT_DIR}/capture"
results_file="${OUTPUT_DIR}/results.json"

touch "${results_file}"

export RUNALL=true
swift test \
    --package-path "${WORKING_DIR}" \
    --xunit-output "${WORKING_DIR}/results.xml" \
    --skip-update &> "${capture_file}"

./bin/TestRunner "${spec_file}" "${junit_file}" "${capture_file}" "${results_file}" "${SLUG}"
