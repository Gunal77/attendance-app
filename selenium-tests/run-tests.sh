#!/bin/bash

# Selenium Test Runner Script
# This script provides convenient commands to run tests

echo "=========================================="
echo "Admin Portal Selenium Test Suite"
echo "=========================================="
echo ""

# Function to display usage
usage() {
    echo "Usage: ./run-tests.sh [option]"
    echo ""
    echo "Options:"
    echo "  all              Run all tests"
    echo "  login            Run login tests only"
    echo "  dashboard        Run dashboard tests only"
    echo "  workers          Run worker management tests only"
    echo "  projects         Run project management tests only"
    echo "  attendance       Run attendance tests only"
    echo "  e2e              Run end-to-end tests only"
    echo "  clean            Clean test output and build"
    echo "  install          Install dependencies"
    echo ""
}

# Function to run all tests
run_all() {
    echo "Running all tests..."
    mvn clean test
}

# Function to run specific test class
run_test_class() {
    local test_class=$1
    echo "Running $test_class..."
    mvn test -Dtest=$test_class
}

# Main script logic
case "$1" in
    all)
        run_all
        ;;
    login)
        run_test_class "LoginTests"
        ;;
    dashboard)
        run_test_class "DashboardTests"
        ;;
    workers)
        run_test_class "WorkerTests"
        ;;
    projects)
        run_test_class "ProjectTests"
        ;;
    attendance)
        run_test_class "AttendanceTests"
        ;;
    e2e)
        run_test_class "EndToEndTests"
        ;;
    clean)
        echo "Cleaning test output and build..."
        mvn clean
        rm -rf test-output/
        echo "Clean completed!"
        ;;
    install)
        echo "Installing dependencies..."
        mvn clean install
        ;;
    *)
        usage
        exit 1
        ;;
esac

echo ""
echo "=========================================="
echo "Test execution completed!"
echo "Check test-output/ for reports and screenshots"
echo "=========================================="

