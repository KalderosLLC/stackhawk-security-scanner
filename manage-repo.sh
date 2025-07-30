#!/bin/bash

# StackHawk Repository Management Commands
echo "🛠️  StackHawk Repository Management"
echo "===================================="
echo ""

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Not in a git repository. Please run from your StackHawk repository."
    exit 1
fi

# Get repository info
REPO_NAME=$(gh repo view --json name --jq .name 2>/dev/null || echo "unknown")
REPO_OWNER=$(gh repo view --json owner --jq .owner.login 2>/dev/null || echo "unknown")

echo "📍 Repository: $REPO_OWNER/$REPO_NAME"
echo ""

# Menu of commands
PS3="Select an action: "
options=(
    "🔍 View repository on GitHub"
    "🚀 Trigger manual scan"
    "📊 Check latest workflow runs"
    "📋 List workflow artifacts"
    "🔑 Update StackHawk API key"
    "🧪 Validate all configurations"
    "🔄 Run local bulk scan"
    "📝 Check repository secrets"
    "🏷️  Create new release"
    "❌ Exit"
)

select opt in "${options[@]}"
do
    case $opt in
        "🔍 View repository on GitHub")
            echo "Opening repository in browser..."
            gh repo view --web
            ;;
        "🚀 Trigger manual scan")
            echo "Triggering manual StackHawk scan..."
            gh workflow run stackhawk-hourly-scan.yml
            echo "✅ Workflow triggered! Check Actions tab for progress."
            ;;
        "📊 Check latest workflow runs")
            echo "Latest workflow runs:"
            gh run list --limit 10
            ;;
        "📋 List workflow artifacts")
            echo "Available artifacts from recent runs:"
            gh run list --limit 5 --json databaseId,conclusion,createdAt | \
            jq -r '.[] | "\(.databaseId) - \(.conclusion) - \(.createdAt)"' | \
            while read run_id conclusion created_at; do
                echo "Run $run_id ($conclusion) - $created_at"
                gh run view $run_id --json artifacts --jq '.artifacts[].name' | sed 's/^/  • /'
            done
            ;;
        "🔑 Update StackHawk API key")
            read -p "Enter new StackHawk API key: " -s NEW_API_KEY
            echo ""
            if [ -n "$NEW_API_KEY" ]; then
                echo "$NEW_API_KEY" | gh secret set HAWK_API_KEY
                echo "✅ API key updated!"
            else
                echo "❌ No API key provided"
            fi
            ;;
        "🧪 Validate all configurations")
            echo "Validating StackHawk configurations..."
            config_count=0
            valid_count=0
            
            for config_file in stackhawk-*.yml; do
                if [ -f "$config_file" ]; then
                    ((config_count++))
                    echo -n "   $config_file: "
                    if hawk validate config "$config_file" &> /dev/null; then
                        echo "✅ Valid"
                        ((valid_count++))
                    else
                        echo "❌ Invalid"
                        hawk validate config "$config_file"
                    fi
                fi
            done
            
            echo ""
            echo "Summary: $valid_count/$config_count configurations are valid"
            ;;
        "🔄 Run local bulk scan")
            echo "Running local bulk scan..."
            if [ -f "bulk-scan-runner.sh" ]; then
                chmod +x bulk-scan-runner.sh
                ./bulk-scan-runner.sh
            else
                echo "❌ bulk-scan-runner.sh not found"
            fi
            ;;
        "📝 Check repository secrets")
            echo "Repository secrets:"
            gh secret list
            ;;
        "🏷️  Create new release")
            read -p "Enter release tag (e.g., v1.0.0): " RELEASE_TAG
            read -p "Enter release title: " RELEASE_TITLE
            read -p "Enter release notes: " RELEASE_NOTES
            
            if [ -n "$RELEASE_TAG" ]; then
                gh release create "$RELEASE_TAG" \
                    --title "${RELEASE_TITLE:-$RELEASE_TAG}" \
                    --notes "${RELEASE_NOTES:-Automated StackHawk security scanner release}"
                echo "✅ Release $RELEASE_TAG created!"
            else
                echo "❌ Release tag is required"
            fi
            ;;
        "❌ Exit")
            echo "👋 Goodbye!"
            break
            ;;
        *) 
            echo "Invalid option $REPLY"
            ;;
    esac
    echo ""
done
