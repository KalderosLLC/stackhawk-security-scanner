#!/bin/bash

# GitHub Actions compatible StackHawk scan runner
echo "🔍 StackHawk GitHub Actions Scan Runner"
echo "======================================="

# Check if we're running in GitHub Actions or locally
if [ -n "$GITHUB_ACTIONS" ]; then
    echo "🚀 Running in GitHub Actions environment"
    # In GitHub Actions, we'll use Docker
    HAWK_CMD="docker run --rm -v \$(pwd):/hawk:rw -e HAWK_API_KEY=\"\$HAWK_API_KEY\" stackhawk/hawkscan"
else
    echo "🏠 Running in local environment"
    # Try to find local StackHawk CLI
    if command -v hawk &> /dev/null; then
        HAWK_CMD="hawk"
    elif [ -f "/opt/homebrew/Cellar/hawk@4.6.0/4.6.0/bin/hawk" ]; then
        HAWK_CMD="/opt/homebrew/Cellar/hawk@4.6.0/4.6.0/bin/hawk"
    else
        echo "❌ StackHawk CLI not found. Please install it or use Docker."
        echo "   Install: brew install stackhawk/hawk/hawk"
        echo "   Or use: ./test-single-scan.sh"
        exit 1
    fi
fi

echo "🛠️  Using: $HAWK_CMD"
echo ""

# Function to run a single scan
run_scan() {
    local config_file="$1"
    local app_name="${config_file%.yml}"
    app_name="${app_name#stackhawk-}"
    
    echo "🦅 Starting scan for: $app_name"
    echo "   Config file: $config_file"
    
    if [ ! -f "$config_file" ]; then
        echo "   ❌ Configuration file not found: $config_file"
        return 1
    fi
    
    # Validate configuration first (if not using Docker)
    if [[ "$HAWK_CMD" != *"docker"* ]]; then
        echo "   📋 Validating configuration..."
        if ! $HAWK_CMD validate config "$config_file"; then
            echo "   ❌ Configuration validation failed"
            return 1
        fi
        echo "   ✅ Configuration valid"
    fi
    
    echo "   🚀 Starting scan..."
    if [[ "$HAWK_CMD" == *"docker"* ]]; then
        # Use Docker command
        if docker run --rm -v "$(pwd):/hawk:rw" -e HAWK_API_KEY="$HAWK_API_KEY" stackhawk/hawkscan "$config_file"; then
            echo "   🎉 Scan completed successfully for $app_name"
            return 0
        else
            echo "   ❌ Scan failed for $app_name"
            return 1
        fi
    else
        # Use local CLI
        if $HAWK_CMD scan "$config_file"; then
            echo "   🎉 Scan completed successfully for $app_name"
            return 0
        else
            echo "   ❌ Scan failed for $app_name"
            return 1
        fi
    fi
}

# Handle command line arguments (same as original script)
case "${1:-}" in
    "list"|"-l"|"--list")
        echo "📱 Available applications:"
        echo ""
        for config_file in stackhawk-*.yml; do
            if [ -f "$config_file" ]; then
                app_name="${config_file%.yml}"
                app_name="${app_name#stackhawk-}"
                echo "   - $app_name ($config_file)"
            fi
        done
        echo ""
        ;;
    "")
        echo "Usage: $0 [OPTIONS] [APPLICATION]"
        echo ""
        echo "Options:"
        echo "  list, -l, --list     List available applications"
        echo "  all, -a, --all       Run scans for all applications"
        echo ""
        echo "Application:"
        echo "  <app-name>           Run scan for specific application"
        echo ""
        ;;
    *)
        # Try to run scan for specific application
        config_file="stackhawk-${1}.yml"
        if [ -f "$config_file" ]; then
            run_scan "$config_file"
        else
            echo "❌ Application '$1' not found."
            echo "   Expected config file: $config_file"
            exit 1
        fi
        ;;
esac
