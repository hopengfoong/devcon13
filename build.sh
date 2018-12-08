#!/usr/bin/env bash

#Colors to be used in console output
LIGHT_GREEN='\033[1;32m'
LIGHT_RED='\033[1;31m'
NO_COLOR='\033[0m'

checkLastCommandSuccess() {
	if [ $? != 0 ]; then
		echo -e "${LIGHT_RED}${1}${NO_COLOR}" 1>&2
		exit -1
	fi
}

current_directory="$(pwd)"
echo "Build starting using directory ${current_directory}"

# Detect if script is being run using Windows Subsystem for Linux
is_wsl=
# sh on Ubuntu on Windows
if uname -a | grep -q '^Linux.*Microsoft'; then
	is_wsl=true
	echo "This script is being run in Windows Subsystem for Linux"
fi

# Build our application image
docker build --file ./src/Devcon.SampleSite/Dockerfile . --tag devcon-samplesite
checkLastCommandSuccess "Error occured while trying to build the samplesite image"

# Build and run the unit test image and its result transformer
# Build the unit test image
docker build --file ./src/Devcon.SampleSite/Dockerfile --target testrunner . --tag devcon-samplesite:testrunner
checkLastCommandSuccess "Error occured while trying to build the testrunner image"

# Build the unit test image
docker build --file ./src/Devcon.SampleSite/Dockerfile --target testresulttransform . --tag devcon-samplesite:testresulttransform
checkLastCommandSuccess "Error occured while trying to build the testresulttransform image"

test_result_folder="${current_directory}/test-results"
echo "Using test result folder: ${test_result_folder}"

mkdir -p "${test_result_folder}"

if [ "$is_wsl" ]; then
	test_result_folder="$(wslpath -w ${test_result_folder})"
	echo "Translating test result folder to ${test_result_folder}"
fi

# Run the unit tests container, but don't exit if there's an error. Only exit after the result is transformed
echo "Running unit tests"
hasTestError=
docker run --rm --volume $test_result_folder:/code/test-results devcon-samplesite:testrunner
if [ $? != 0 ]; then
	hasTestError=true
fi

# Transform the unit tests results to JUnit's format
echo "Transforming unit tests results"
docker run --rm --volume $test_result_folder:/code/test-results devcon-samplesite:testresulttransform
checkLastCommandSuccess "Error transforming unit tests results"

if [ $hasTestError ]; then
	echo -e "${LIGHT_RED}An error occurred when running the tests.${NO_COLOR}" 1>&2
	exit -1
fi

echo "Build completed successfully"