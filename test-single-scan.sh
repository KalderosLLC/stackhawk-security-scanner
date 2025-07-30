#!/bin/bash

# Test single StackHawk scan with detailed error output
echo "🔍 StackHawk Single Scan Tester"
echo "==============================="

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed or not running"
    exit 1
fi

# Get the first available config file
CONFIG_FILE=$(ls stackhawk-*.yml 2>/dev/null | head -1)

if [ -z "$CONFIG_FILE" ]; then
    echo "❌ No StackHawk configuration files found"
    exit 1
fi

echo "📁 Testing with: $CONFIG_FILE"
echo ""

# Check if HAWK_API_KEY is set
if [ -z "$HAWK_API_KEY" ]; then
    echo "⚠️  HAWK_API_KEY environment variable not set"
    read -p "Enter your StackHawk API key: " -s HAWK_API_KEY
    echo ""
    export HAWK_API_KEY
fi

echo "🐳 Pulling StackHawk Docker image..."
docker pull stackhawk/hawkscan:latest

echo ""
echo "🦅 Running test scan..."
echo "======================================="

# Run the scan with verbose output
docker run --rm -v "$(pwd):/hawk:rw" -e HAWK_API_KEY="$HAWK_API_KEY" stackhawk/hawkscan --verbose "$CONFIG_FILE"

SCAN_RESULT=$?

echo ""
echo "======================================="
if [ $SCAN_RESULT -eq 0 ]; then
    echo "✅ Test scan completed successfully!"
else
    echo "❌ Test scan failed with exit code: $SCAN_RESULT"
    echo ""
    echo "💡 Common issues:"
    echo "   - Invalid API key"
    echo "   - Application not accessible from GitHub runners"
    echo "   - Missing required fields in YAML configuration"
    echo "   - Network connectivity issues"
    echo ""
    echo "🔧 Try running locally with:"
    echo "   export HAWK_API_KEY='your-api-key'"
    echo "   ./test-single-scan.sh"
fi
