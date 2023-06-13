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

docker compose up --build -d --wait
containerStartedTS=$(date +%s)

# building can take more time on first run. -> flaky tests
# however, we try to keep test-runs as fast as possible
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
else
  echo "Successfully ran tests"
fi
