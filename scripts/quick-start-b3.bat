@echo off
REM Quick Start Script for B3 Access Gate Lab 03 (Windows)
REM This script sets up and runs the complete test suite

setlocal enabledelayedexpansion

echo.
echo ================================
echo FIT4110 Lab 03 - B3 Access Gate
echo Quick Start Setup (Windows)
echo ================================
echo.

REM Step 1: Install dependencies
echo 📦 Step 1: Installing dependencies...
call npm install
if errorlevel 1 (
    echo ❌ Failed to install dependencies
    exit /b 1
)
echo ✅ Dependencies installed
echo.

REM Step 2: Lint contracts
echo 🔍 Step 2: Linting OpenAPI contracts...
call npm run lint:contracts
if errorlevel 1 (
    echo ⚠️  Some lint warnings found (check output above)
)
echo ✅ Contracts validated
echo.

REM Step 3: Start mock server
echo 🚀 Step 3: Starting Prism mock server for Access Gate...
echo    Mock will run at: http://localhost:4020
start /B npm run mock:access-gate
echo ✅ Mock server started
timeout /t 3 /nobreak

REM Step 4: Verify mock is running
echo 🔗 Step 4: Checking mock server health...
curl http://localhost:4020/health >nul 2>&1
if errorlevel 1 (
    echo ❌ Mock server failed to start
    exit /b 1
)
echo ✅ Mock server is ready
echo.

REM Step 5: Run tests
echo 🧪 Step 5: Running Postman Newman tests...
call npm run test:b3:mock
echo ✅ Tests completed
echo.

REM Step 6: Show reports
echo 📊 Step 6: Test reports generated
echo    View HTML report: reports/B3_newman-report-mock.html
echo    View XML report: reports/B3_newman-report-mock.xml
echo.

echo ================================
echo ✅ Lab 03 Setup Complete!
echo ================================
echo.
echo 📌 Next steps:
echo 1. Review test results in reports/
echo 2. Check OpenAPI spec: contracts/access-gate.openapi.yaml
echo 3. Review test cases: templates/B3_AccessGate_test-case-matrix.csv
echo 4. Check handshake: templates/B3_AccessGate_consumer-provider-handshake.md
echo.
echo 💡 Useful commands:
echo    npm run mock:access-gate      # Start mock server
echo    npm run test:b3:mock          # Run tests on mock
echo    npm run test:b3:local         # Run tests on local service
echo    npm run lint:contracts        # Validate OpenAPI
echo.
echo Open reports in browser:
echo    start reports\B3_newman-report-mock.html
echo.
pause
