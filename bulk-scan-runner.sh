#!/bin/bash

# StackHawk Bulk Scan Runner
# This script loops through all StackHawk configuration files and runs scan-runner.sh for each one
# Reports successes and failures with detailed output

# Don't exit on errors - we want to continue processing all configs even if some fail
set +e

echo "🔍 StackHawk Bulk Scan Runner"
echo "=============================="
echo ""

# Initialize counters and arrays
total_count=0
success_count=0
failure_count=0
declare -a successful_scans=()
declare -a failed_scans=()
start_time=$(date +%s)

# Create log file with timestamp
log_file="bulk-scan-results-$(date +%Y%m%d-%H%M%S).log"
echo "📝 Logging results to: $log_file"
echo ""

# Function to log with timestamp
log_with_timestamp() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $message" | tee -a "$log_file"
}

# Function to run scan for a single config
run_single_scan() {
    local config_file="$1"
    local app_name="${config_file%.yml}"
    app_name="${app_name#stackhawk-}"
    
    echo "🦅 Processing: $app_name"
    echo "   Config: $config_file"
    log_with_timestamp "Starting scan for $app_name using $config_file"
    
    if [ ! -f "$config_file" ]; then
        echo "   ❌ Configuration file not found: $config_file"
        log_with_timestamp "ERROR: Configuration file not found: $config_file"
        failed_scans+=("$app_name (file not found)")
        ((failure_count++))
        return 1
    fi
    
    # Run the scan using scan-runner.sh
    echo "   🚀 Running scan..."
    if ./scan-runner.sh "$app_name" >> "$log_file" 2>&1; then
        echo "   ✅ SUCCESS: $app_name scan completed"
        log_with_timestamp "SUCCESS: $app_name scan completed successfully"
        successful_scans+=("$app_name")
        ((success_count++))
        return 0
    else
        echo "   ❌ FAILED: $app_name scan failed"
        log_with_timestamp "FAILURE: $app_name scan failed"
        failed_scans+=("$app_name")
        ((failure_count++))
        return 1
    fi
}

# Main execution
log_with_timestamp "Starting bulk scan process"
echo "🔄 Starting bulk scan for all StackHawk configurations..."
echo ""

# Loop through all stackhawk-*.yml files
for config_file in stackhawk-*.yml; do
    if [ -f "$config_file" ]; then
        ((total_count++))
        run_single_scan "$config_file"
        echo ""
        
        # Add a small delay between scans to avoid overwhelming the system
        sleep 2
    fi
done

# Calculate execution time
end_time=$(date +%s)
execution_time=$((end_time - start_time))
execution_minutes=$((execution_time / 60))
execution_seconds=$((execution_time % 60))

# Generate final report
echo "=================================="
echo "🏁 BULK SCAN COMPLETED"
echo "=================================="
echo ""
echo "📊 SUMMARY:"
echo "   Total configurations: $total_count"
echo "   Successful scans: $success_count"
echo "   Failed scans: $failure_count"
echo "   Success rate: $(( success_count * 100 / total_count ))%"
echo "   Execution time: ${execution_minutes}m ${execution_seconds}s"
echo ""

# Log summary
log_with_timestamp "Bulk scan completed - Total: $total_count, Success: $success_count, Failed: $failure_count"

if [ ${#successful_scans[@]} -gt 0 ]; then
    echo "✅ SUCCESSFUL SCANS:"
    for scan in "${successful_scans[@]}"; do
        echo "   ✓ $scan"
    done
    echo ""
fi

if [ ${#failed_scans[@]} -gt 0 ]; then
    echo "❌ FAILED SCANS:"
    for scan in "${failed_scans[@]}"; do
        echo "   ✗ $scan"
    done
    echo ""
    
    echo "💡 Check the log file for detailed error information: $log_file"
    echo ""
fi

# Exit with appropriate code
if [ $failure_count -eq 0 ]; then
    echo "🎉 All scans completed successfully!"
    log_with_timestamp "All scans completed successfully"
    exit 0
else
    echo "⚠️  Some scans failed. Check the details above and in the log file."
    log_with_timestamp "Bulk scan completed with $failure_count failures"
    exit 1
fi
