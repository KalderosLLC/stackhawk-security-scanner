#!/bin/bash

# StackHawk Multi-Application Scan Runner
# This script runs security scans for multiple StackHawk applications

set -e

echo "🔍 StackHawk Multi-Application Scan Runner"
echo "=========================================="
echo ""

# Path to the newer StackHawk CLI
HAWK_CLI="/opt/homebrew/Cellar/hawk@4.6.0/4.6.0/bin/hawk"

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
    
    # Validate configuration first
    echo "   📋 Validating configuration..."
    if ! $HAWK_CLI validate config "$config_file"; then
        echo "   ❌ Configuration validation failed"
        return 1
    fi
    
    echo "   ✅ Configuration valid, starting scan..."
    if $HAWK_CLI scan "$config_file"; then
        echo "   🎉 Scan completed successfully for $app_name"
        echo ""
        return 0
    else
        echo "   ❌ Scan failed for $app_name"
        echo ""
        return 1
    fi
}

# Function to list available applications
list_apps() {
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
}

# Function to run scans for specific environment
run_environment_scans() {
    local env="$1"
    echo "🌍 Running scans for $env environment..."
    echo ""
    
    local count=0
    for config_file in stackhawk-*-${env}.yml; do
        if [ -f "$config_file" ]; then
            run_scan "$config_file"
            ((count++))
        fi
    done
    
    if [ $count -eq 0 ]; then
        echo "   ⚠️  No configuration files found for $env environment"
    else
        echo "🏁 Completed $count scans for $env environment"
    fi
}

# Parse command line arguments
case "${1:-}" in
    "list"|"-l"|"--list")
        list_apps
        ;;
    "all"|"-a"|"--all")
        echo "🔄 Running scans for ALL applications..."
        echo ""
        success_count=0
        total_count=0
        
        for config_file in stackhawk-*.yml; do
            if [ -f "$config_file" ]; then
                ((total_count++))
                if run_scan "$config_file"; then
                    ((success_count++))
                fi
            fi
        done
        
        echo "📊 Scan Summary:"
        echo "   Total: $total_count"
        echo "   Successful: $success_count"
        echo "   Failed: $((total_count - success_count))"
        ;;
    "prod"|"production")
        run_environment_scans "prod"
        ;;
    "test"|"testing")
        run_environment_scans "test"
        ;;
    "stage"|"staging")
        run_environment_scans "stage"
        ;;
    "dev"|"development")
        run_environment_scans "dev"
        ;;
    "")
        echo "Usage: $0 [OPTIONS] [APPLICATION]"
        echo ""
        echo "Options:"
        echo "  list, -l, --list     List available applications"
        echo "  all, -a, --all       Run scans for all applications"
        echo "  prod                 Run scans for production environment"
        echo "  test                 Run scans for test environment"
        echo "  stage                Run scans for staging environment"
        echo "  dev                  Run scans for development environment"
        echo ""
        echo "Application:"
        echo "  <app-name>           Run scan for specific application"
        echo ""
        echo "Examples:"
        echo "  $0 list                          # List all available apps"
        echo "  $0 all                           # Run all scans"
        echo "  $0 prod                          # Run all production scans"
        echo "  $0 verify-web-prod              # Run specific app scan"
        echo ""
        list_apps
        ;;
    *)
        # Try to run scan for specific application
        config_file="stackhawk-${1}.yml"
        if [ -f "$config_file" ]; then
            run_scan "$config_file"
        else
            echo "❌ Application '$1' not found."
            echo "   Expected config file: $config_file"
            echo ""
            echo "Available applications:"
            list_apps
            exit 1
        fi
        ;;
esac
