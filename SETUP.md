# StackHawk Scanner Repository

## Repository Contents

This folder contains all the essential files needed to run automated StackHawk security scans:

### 🔧 Core Scripts
- `bulk-scan-runner.sh` - Main script that runs all StackHawk configurations
- `scan-runner.sh` - Individual scan runner used by bulk-scan-runner

### ⚙️ Configuration Files  
- `stackhawk-*.yml` - StackHawk configuration files for each application/environment
- `.env` - Environment variables with application URLs
- `stackhawk-app-ids.txt` - Application IDs (if available)

### 🚀 GitHub Actions
- `.github/workflows/stackhawk-hourly-scan.yml` - Automated hourly scanning workflow

### 📚 Documentation
- `README.md` - Complete setup and usage instructions

## Setup Instructions

1. **Create a new GitHub repository**
2. **Copy all these files to your new repository**
3. **Add GitHub Secret**: `HAWK_API_KEY` with your StackHawk API key
4. **Push to GitHub** - the workflow will start running automatically

## Current Configuration

✅ **Applications Configured:**
- Verify (Web & API): prod, test, stage
- Grappa (Web & API): prod, test, stage  
- Request (Web & API): dev, prod
- Pay (Web & API): dev, prod

✅ **Features:**
- Hourly automated scans
- Manual trigger capability
- Result logging and artifact upload
- Failure tolerance (continues even if some scans fail)

The workflow is ready to run as-is once you set up the GitHub repository and API key!
