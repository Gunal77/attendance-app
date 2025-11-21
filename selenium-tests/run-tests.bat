@echo off
REM Selenium Test Runner Script for Windows
REM This script provides convenient commands to run tests

echo ==========================================
echo Admin Portal Selenium Test Suite
echo ==========================================
echo.

if "%1"=="" goto usage
if "%1"=="all" goto run_all
if "%1"=="login" goto run_login
if "%1"=="dashboard" goto run_dashboard
if "%1"=="workers" goto run_workers
if "%1"=="projects" goto run_projects
if "%1"=="attendance" goto run_attendance
if "%1"=="e2e" goto run_e2e
if "%1"=="clean" goto clean
if "%1"=="install" goto install
goto usage

:run_all
echo Running all tests...
call mvn clean test
goto end

:run_login
echo Running LoginTests...
call mvn test -Dtest=LoginTests
goto end

:run_dashboard
echo Running DashboardTests...
call mvn test -Dtest=DashboardTests
goto end

:run_workers
echo Running WorkerTests...
call mvn test -Dtest=WorkerTests
goto end

:run_projects
echo Running ProjectTests...
call mvn test -Dtest=ProjectTests
goto end

:run_attendance
echo Running AttendanceTests...
call mvn test -Dtest=AttendanceTests
goto end

:run_e2e
echo Running EndToEndTests...
call mvn test -Dtest=EndToEndTests
goto end

:clean
echo Cleaning test output and build...
call mvn clean
if exist test-output rmdir /s /q test-output
echo Clean completed!
goto end

:install
echo Installing dependencies...
call mvn clean install
goto end

:usage
echo Usage: run-tests.bat [option]
echo.
echo Options:
echo   all              Run all tests
echo   login            Run login tests only
echo   dashboard        Run dashboard tests only
echo   workers          Run worker management tests only
echo   projects         Run project management tests only
echo   attendance       Run attendance tests only
echo   e2e              Run end-to-end tests only
echo   clean            Clean test output and build
echo   install          Install dependencies
echo.
goto end

:end
echo.
echo ==========================================
echo Test execution completed!
echo Check test-output\ for reports and screenshots
echo ==========================================

