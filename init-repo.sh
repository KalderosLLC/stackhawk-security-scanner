#!/bin/bash

# Initialize StackHawk Scanner Repository
echo "🔍 Initializing StackHawk Scanner Repository"
echo "=============================================="
echo ""

# Check if git is available
if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed. Please install git first."
    exit 1
fi

# Initialize git repository
echo "📁 Initializing git repository..."
git init

# Add all files
echo "📋 Adding files to git..."
git add .

# Initial commit
echo "💾 Creating initial commit..."
git commit -m "Initial commit: StackHawk automated security scanner

- Hourly GitHub Actions workflow for automated scanning
- Bulk scan runner for all StackHawk configurations  
- Individual scan runner for targeted scans
- Configuration files for Verify, Grappa, Request, and Pay applications
- Environment variables for Azure application URLs
- Complete documentation and setup instructions"

echo ""
echo "✅ Repository initialized successfully!"
echo ""
echo "📝 Next steps:"
echo "1. Create a new repository on GitHub"
echo "2. Add the remote origin:"
echo "   git remote add origin <your-github-repo-url>"
echo "3. Push to GitHub:"
echo "   git branch -M main"
echo "   git push -u origin main"
echo "4. Add GitHub secret 'HAWK_API_KEY' with your StackHawk API key"
echo "5. The workflow will start running automatically!"
echo ""
echo "🦅 Happy scanning!"
