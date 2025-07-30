#!/bin/bash

# Quick StackHawk Repository Setup (Skip Validation)
echo "⚡ Quick StackHawk Repository Setup"
echo "==================================="
echo ""

# Check if required tools are available
if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed. Please install git first."
    exit 1
fi

if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed."
    echo "   Install it from: https://cli.github.com/"
    exit 1
fi

# Check GitHub CLI authentication
if ! gh auth status &> /dev/null; then
    echo "❌ GitHub CLI is not authenticated."
    echo "   Please run: gh auth login"
    exit 1
fi

echo "✅ Tools ready!"
echo ""

# Get repository details
read -p "📝 Enter organization name (kalderosllc): " ORG_NAME
ORG_NAME=${ORG_NAME:-kalderosllc}

read -p "📝 Enter repository name (stackhawk-security-scanner): " REPO_NAME
REPO_NAME=${REPO_NAME:-stackhawk-security-scanner}

read -p "📝 Enter repository description (optional): " REPO_DESC
REPO_DESC=${REPO_DESC:-"Automated StackHawk security scanning for Azure applications"}

echo ""
echo "📁 Creating: $ORG_NAME/$REPO_NAME"

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

# Create GitHub repository in organization
echo ""
echo "🚀 Creating GitHub repository in $ORG_NAME organization..."

if [ -n "$REPO_DESC" ]; then
    gh repo create "$ORG_NAME/$REPO_NAME" --description "$REPO_DESC" --public --source=. --remote=origin --push
else
    gh repo create "$ORG_NAME/$REPO_NAME" --public --source=. --remote=origin --push
fi

echo ""
echo "✅ Repository created and pushed!"

# Set up API key
echo ""
echo "🔑 Setting up StackHawk API key..."
read -p "Enter your StackHawk API key: " -s HAWK_API_KEY
echo ""

if [ -z "$HAWK_API_KEY" ]; then
    echo "⚠️  No API key provided. You'll need to add it manually:"
    echo "   Go to: https://github.com/$ORG_NAME/$REPO_NAME/settings/secrets/actions"
    echo "   Add secret: HAWK_API_KEY"
else
    echo "🔐 Adding HAWK_API_KEY to repository secrets..."
    echo "$HAWK_API_KEY" | gh secret set HAWK_API_KEY
    echo "✅ API key added!"
fi

# Count configurations
config_count=$(ls stackhawk-*.yml 2>/dev/null | wc -l)

# Final summary
echo ""
echo "🎉 Quick Setup Complete!"
echo "========================"
echo ""
echo "📍 Repository: https://github.com/$ORG_NAME/$REPO_NAME"
echo "📊 Configurations: $config_count StackHawk files"
echo ""
echo "✅ What's ready:"
echo "   • Repository created in $ORG_NAME organization"
echo "   • GitHub Actions workflow configured (runs hourly)"
echo "   • StackHawk API key set up"
echo "   • All configuration files uploaded"
echo ""
echo "🚀 Next steps:"
echo "   1. Visit repository: gh repo view --web"
echo "   2. Check Actions tab - first scan may start automatically"
echo "   3. Trigger manual scan: gh workflow run stackhawk-hourly-scan.yml"
echo ""
echo "🦅 Happy scanning!"
