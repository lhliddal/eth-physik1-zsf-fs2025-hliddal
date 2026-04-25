#!/bin/bash

# Default values
TEST_FILE=$1
TEST_DIR="tests"
BUILD_DIR="${TEST_DIR}/build"

if [ -z "$TEST_FILE" ]; then
    echo "Usage: ./tests/run_test.sh <test_name.tex>"
    echo "Files available in ${TEST_DIR}:"
    ls -1 ${TEST_DIR}/*.tex | sed 's|^tests/||'
    exit 1
fi

# Ensure test file has .tex extension
if [[ ! "$TEST_FILE" == *.tex ]]; then
    TEST_FILE="${TEST_FILE}.tex"
fi

# Check if file exists
if [ ! -f "${TEST_DIR}/${TEST_FILE}" ]; then
    echo "Error: Test file ${TEST_DIR}/${TEST_FILE} not found!"
    exit 1
fi

mkdir -p "$BUILD_DIR"

echo "Running test: $TEST_FILE"
latexmk -synctex=1 -interaction=nonstopmode -file-line-error -pdf -outdir="$BUILD_DIR" -auxdir="$BUILD_DIR" "${TEST_DIR}/${TEST_FILE}"

echo ""
echo "Output PDF: ${BUILD_DIR}/${TEST_FILE%.*}.pdf"
