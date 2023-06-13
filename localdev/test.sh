#!/bin/bash

source "./testing.sh"
source "./test_mapping.sh"
source "./test_sha.sh"

# so that the script can be called from any directory
originalWd=$(pwd)
cd "$(dirname $0)"
baseDir=$(pwd)
trap 'cd $originalWd' EXIT

docker compose down #incase

beforeStartSHA
beforeStartMapping

sleep 1

docker compose up --build -d --wait
containerStartedTS=$(date +%s)

sleep 1 # so the container has time do initial copying and initialize the watches

# shared by all test. set to false to make test fail
success="true"

afterStartMapping
afterStartSHA


# cleanup
cd "$baseDir"

rm -rf volumes/src/*
rm -rf volumes/target/*

docker compose down -t 0

if [ $success = "false" ]; then
  echo "Tests failed"
  echo "Note that tests related to modification-time are flaky. Run again in case tests for timestamps fail"
else
  echo "Successfully ran tests"
fi
