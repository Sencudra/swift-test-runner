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
    CONFIG_FILE="${INPUT_DIR}/.meta/config.json"
    SOURCE_TARGET_PATH="${WORKING_DIR}/Sources/TestEnvironment"
    TEST_TARGET_PATH="${WORKING_DIR}/Tests/TestEnvironmentTests"

    # 1. Replace source files with those of an exercise, saving TestEnvironement paths
    rm -Rf $SOURCE_TARGET_PATH $TEST_TARGET_PATH

    target_name=$(jq -r '.files.solution[0]' $CONFIG_FILE | xargs dirname | xargs basename)
    test_target_name=$(jq -r '.files.test[0]' $CONFIG_FILE | xargs dirname | xargs basename)

    # Copying everything from package in case of other targets.
    cp -rf "${INPUT_DIR}/Sources/." "${WORKING_DIR}/Sources"
    cp -rf "${INPUT_DIR}/Tests/." "${WORKING_DIR}/Tests"

    mv "${WORKING_DIR}/Sources/${target_name}" $SOURCE_TARGET_PATH
    mv "${WORKING_DIR}/Tests/${test_target_name}" $TEST_TARGET_PATH

    # 2. Replace @testable import SomeModule with @testable import TestEnvironment
    sed -i 's/@testable import [^ ]\+/@testable import TestEnvironment/g' "${WORKING_DIR}/Tests/TestEnvironmentTests"/*.swift

    # 3. Copy Package.swift and rename main & test targets.
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
