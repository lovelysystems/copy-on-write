#!/bin/bash

source "./test_mapping.sh"
source "./test_sha.sh"
source "./test_delete.sh"

PROJECT_NAME="copy_on_write_tests"

cleanup() {
  docker compose -p $PROJECT_NAME down -t 1

  cd "$baseDir"
  rm -rf volumes/src/*
  rm -rf volumes/target/*
}

# so that the script can be called from any directory
originalWd=$(pwd)
cd "$(dirname $0)"
baseDir=$(pwd)
trap 'cd $originalWd' EXIT

# cleanup before tests (in case previous test run has not finished)
cleanup

beforeStartMapping
beforeStartSHA
beforeStartDelete

# wait one seconds to ensure a startuptime distinct to content created before startup
sleep 1
containerStartedTS=$(date +%s)

docker compose -p $PROJECT_NAME up --build -d --wait

sleep 1 # so the container has time do initial copying and initialize the watches

# shared by all test. set to false to make test fail
success="true"

afterStartMapping
afterStartSHA
afterStartDelete

cleanup

if [ $success = "false" ]; then
  echo "Tests failed"
  echo "Note that tests related to modification-time are flaky. Run again in case tests for timestamps fail"
else
  echo "Successfully ran tests"
fi
