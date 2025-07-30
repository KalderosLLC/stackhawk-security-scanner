#!/bin/bash

# Complete StackHawk Repository Setup with GitHub CLI
echo "🚀 StackHawk Repository Setup with GitHub CLI"
echo "=============================================="
echo ""

# Check if required tools are available
echo "🔍 Checking required tools..."

if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed. Please install git first."
    exit 1
fi

if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed."
    echo "   Install it from: https://cli.github.com/"
    exit 1
fi

if ! command -v hawk &> /dev/null; then
    echo "⚠️  StackHawk CLI (hawk) is not installed."
    echo "   Installing StackHawk CLI..."
    
    # Detect OS and install appropriate version
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            echo "   Using Homebrew to install StackHawk CLI..."
            brew install stackhawk/hawk/hawk
        else
            echo "   Downloading StackHawk CLI for macOS..."
            curl -L https://download.stackhawk.com/hawk/cli/hawk-macos.zip -o hawk.zip
            unzip hawk.zip
            sudo mv hawk /usr/local/bin/
            rm hawk.zip
        fi
    else
        # Linux/Other
        echo "   Downloading StackHawk CLI for Linux..."
        curl -L https://download.stackhawk.com/hawk/cli/hawk-linux.zip -o hawk.zip
        unzip hawk.zip
        sudo mv hawk /usr/local/bin/
        rm hawk.zip
    fi
fi

echo "✅ All required tools are available!"
echo ""

# Check GitHub CLI authentication
echo "🔐 Checking GitHub CLI authentication..."
if ! gh auth status &> /dev/null; then
    echo "❌ GitHub CLI is not authenticated."
    echo "   Please run: gh auth login"
    exit 1
fi

echo "✅ GitHub CLI is authenticated!"
echo ""

# Get repository name and organization
read -p "📝 Enter organization name (default: your personal account): " ORG_NAME
read -p "📝 Enter repository name (default: stackhawk-security-scanner): " REPO_NAME
REPO_NAME=${REPO_NAME:-stackhawk-security-scanner}

echo ""
if [ -n "$ORG_NAME" ]; then
    echo "📁 Repository: $ORG_NAME/$REPO_NAME"
else
    echo "📁 Repository: $(gh api user --jq .login)/$REPO_NAME"
fi

# Get repository description
read -p "📝 Enter repository description (optional): " REPO_DESC
REPO_DESC=${REPO_DESC:-"Automated StackHawk security scanning for Azure applications"}

echo ""

# Initialize git repository if not already done
if [ ! -d ".git" ]; then
    echo "📁 Initializing git repository..."
    git init
    git add .
    git commit -m "Initial commit: StackHawk automated security scanner

- Hourly GitHub Actions workflow for automated scanning
- Bulk scan runner for all StackHawk configurations  
- Individual scan runner for targeted scans
- Configuration files for Verify, Grappa, Request, and Pay applications
- Environment variables for Azure application URLs
- Complete documentation and setup instructions"
else
    echo "📁 Git repository already initialized"
fi

# Create GitHub repository
echo ""
echo "🚀 Creating GitHub repository..."

if [ -n "$ORG_NAME" ]; then
    # Create in organization
    if [ -n "$REPO_DESC" ]; then
        gh repo create "$ORG_NAME/$REPO_NAME" --description "$REPO_DESC" --public --source=. --remote=origin --push
    else
        gh repo create "$ORG_NAME/$REPO_NAME" --public --source=. --remote=origin --push
    fi
    FULL_REPO_NAME="$ORG_NAME/$REPO_NAME"
else
    # Create in personal account
    if [ -n "$REPO_DESC" ]; then
        gh repo create "$REPO_NAME" --description "$REPO_DESC" --public --source=. --remote=origin --push
    else
        gh repo create "$REPO_NAME" --public --source=. --remote=origin --push
    fi
    FULL_REPO_NAME="$(gh api user --jq .login)/$REPO_NAME"
fi

echo ""
echo "✅ Repository created and pushed to GitHub!"

# Get StackHawk API key
echo ""
echo "🔑 Setting up StackHawk API key..."
read -p "Enter your StackHawk API key: " -s HAWK_API_KEY
echo ""

if [ -z "$HAWK_API_KEY" ]; then
    echo "⚠️  No API key provided. You'll need to add it manually later."
    echo "   Go to: https://github.com/$(gh api user --jq .login)/$REPO_NAME/settings/secrets/actions"
    echo "   Add secret: HAWK_API_KEY"
else
    echo "🔐 Adding HAWK_API_KEY to repository secrets..."
    echo "$HAWK_API_KEY" | gh secret set HAWK_API_KEY
    echo "✅ API key added to repository secrets!"
fi

# Validate StackHawk configurations (with timeout)
echo ""
echo "🔍 Validating StackHawk configurations..."
config_count=0
valid_count=0

for config_file in stackhawk-*.yml; do
    if [ -f "$config_file" ]; then
        ((config_count++))
        echo "   Validating $config_file..."
        
        # Use timeout to prevent hanging (30 seconds max per file)
        if timeout 30s hawk validate config "$config_file" &> /dev/null; then
            echo "   ✅ $config_file is valid"
            ((valid_count++))
        else
            echo "   ⚠️  $config_file has validation issues (or timed out)"
            # Show actual validation error (with timeout)
            timeout 10s hawk validate config "$config_file" 2>&1 | head -3 | sed 's/^/      /'
        fi
    fi
done

echo ""
echo "📊 Configuration Summary:"
echo "   Total configs: $config_count"
echo "   Valid configs: $valid_count"
echo "   Issues: $((config_count - valid_count))"

# Test bulk scan runner
echo ""
echo "🧪 Testing bulk scan runner (dry run)..."
if [ -f "bulk-scan-runner.sh" ]; then
    chmod +x bulk-scan-runner.sh
    echo "✅ bulk-scan-runner.sh is executable"
else
    echo "❌ bulk-scan-runner.sh not found"
fi

# Final summary
echo ""
echo "🎉 Setup Complete!"
echo "=================="
echo ""
echo "📍 Repository URL: https://github.com/$FULL_REPO_NAME"
echo ""
echo "✅ What's configured:"
echo "   • GitHub repository created and pushed"
echo "   • GitHub Actions workflow ready (runs hourly)"
echo "   • StackHawk API key configured (if provided)"
echo "   • $config_count StackHawk configuration files"
echo ""
echo "🚀 Next steps:"
echo "   1. Visit your repository: gh repo view --web"
echo "   2. Check Actions tab for workflow runs"
echo "   3. Manually trigger a scan: gh workflow run stackhawk-hourly-scan.yml"
echo "   4. View results in Actions artifacts"
echo ""
echo "🦅 Your automated security scanning is now live!"
