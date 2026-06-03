#!/bin/bash
# Quick Start Script for B3 Access Gate Lab 03
# This script sets up and runs the complete test suite

set -e

echo "================================"
echo "FIT4110 Lab 03 - B3 Access Gate"
echo "Quick Start Setup"
echo "================================"
echo ""

# Step 1: Install dependencies
echo "📦 Step 1: Installing dependencies..."
npm install
echo "✅ Dependencies installed"
echo ""

# Step 2: Lint contracts
echo "🔍 Step 2: Linting OpenAPI contracts..."
npm run lint:contracts
echo "✅ Contracts validated"
echo ""

# Step 3: Start mock server
echo "🚀 Step 3: Starting Prism mock server for Access Gate..."
echo "   Mock will run at: http://localhost:4020"
nohup npm run mock:access-gate > prism-gate.log 2>&1 &
MOCK_PID=$!
echo "✅ Mock server started (PID: $MOCK_PID)"
sleep 3

# Step 4: Verify mock is running
echo "🔗 Step 4: Checking mock server health..."
if curl -s http://localhost:4020/health > /dev/null; then
  echo "✅ Mock server is ready"
else
  echo "❌ Mock server failed to start"
  cat prism-gate.log
  exit 1
fi
echo ""

# Step 5: Run tests
echo "🧪 Step 5: Running Postman Newman tests..."
npm run test:b3:mock
echo "✅ Tests completed"
echo ""

# Step 6: Show reports
echo "📊 Step 6: Test reports generated"
echo "   View HTML report: reports/B3_newman-report-mock.html"
echo "   View XML report: reports/B3_newman-report-mock.xml"
echo ""

echo "================================"
echo "✅ Lab 03 Setup Complete!"
echo "================================"
echo ""
echo "📌 Next steps:"
echo "1. Review test results in reports/"
echo "2. Check OpenAPI spec: contracts/access-gate.openapi.yaml"
echo "3. Review test cases: templates/B3_AccessGate_test-case-matrix.csv"
echo "4. Check handshake: templates/B3_AccessGate_consumer-provider-handshake.md"
echo ""
echo "💡 Useful commands:"
echo "   npm run mock:access-gate      # Start mock server"
echo "   npm run test:b3:mock          # Run tests on mock"
echo "   npm run test:b3:local         # Run tests on local service"
echo "   npm run lint:contracts        # Validate OpenAPI"
echo ""
