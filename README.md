# StackHawk Security Scanner

Automated security scanning for Azure applications using StackHawk.

## 🔍 Overview

This repository contains automated StackHawk security scans that run hourly via GitHub Actions. It scans multiple Azure applications across different environments (prod, test, stage, dev).

## 🚀 Quick Start

### Prerequisites

1. **StackHawk Account**: Sign up at [stackhawk.com](https://www.stackhawk.com)
2. **GitHub Repository Secrets**: Add your StackHawk API key

### Setup

1. **Clone this repository**
   ```bash
   git clone <your-repo-url>
   cd stackhawk-scanner
   ```

2. **Add GitHub Secret**
   - Go to repository Settings → Secrets and variables → Actions
   - Create new secret: `HAWK_API_KEY` with your StackHawk API key

3. **Verify Configuration**
   ```bash
   # Check configuration files
   ls stackhawk-*.yml
   
   # Test locally (optional)
   ./bulk-scan-runner.sh
   ```

## 📁 Repository Structure

```
├── .github/workflows/
│   └── stackhawk-hourly-scan.yml    # GitHub Action workflow
├── bulk-scan-runner.sh              # Main bulk scanning script
├── scan-runner.sh                   # Individual scan runner
├── stackhawk-*.yml                  # StackHawk configuration files
├── .env                             # Environment variables
└── README.md                        # This file
```

## 🕐 Automated Scanning

### Schedule
- **Hourly**: Runs every hour at minute 0 (9:00, 10:00, 11:00, etc.)
- **Manual**: Can be triggered manually via GitHub Actions UI

### Applications Scanned
- **Verify**: Web and API (prod, test, stage)
- **Grappa**: Web and API (prod, test, stage)  
- **Request**: Web and API (dev, prod)
- **Pay**: Web and API (dev, prod)

## 🛠️ Local Development

### Run All Scans
```bash
./bulk-scan-runner.sh
```

### Run Individual Scan
```bash
./scan-runner.sh <app-name>
# Example:
./scan-runner.sh verify-web-prod
```

### Available Commands
```bash
./scan-runner.sh list              # List all available apps
./scan-runner.sh all               # Run all scans
./scan-runner.sh prod              # Run only production scans
```

## 📊 Results

### GitHub Actions
- Check the **Actions** tab for workflow runs
- Download scan results from **Artifacts**
- View summaries in workflow logs

### Log Files
- Local runs create timestamped log files: `bulk-scan-results-YYYYMMDD-HHMMSS.log`
- GitHub Actions upload logs as downloadable artifacts

## 🔧 Configuration

### Environment Variables
Update `.env` with your application URLs:

```bash
# Verify Applications
VERIFY_WEB_PROD_HOST=https://verify-web-prod-northcentral.azurewebsites.net
VERIFY_API_PROD_HOST=https://verify-api-prod-northcentral.azurewebsites.net

# Grappa Applications  
GRAPPA_WEB_PROD_HOST=https://kalderos-ce-web-prod.azurewebsites.net
GRAPPA_API_PROD_HOST=https://kalderos-ce-api-prod.azurewebsites.net

# ... and so on
```

### StackHawk Configs
Each `stackhawk-*.yml` file contains:
- Application ID
- Target host URL
- Scan configuration
- Environment settings

## 🚨 Troubleshooting

### Common Issues

1. **Scan Failures**
   - Check application URLs in `.env`
   - Verify StackHawk API key
   - Ensure applications are accessible

2. **GitHub Action Failures**
   - Check if `HAWK_API_KEY` secret is set
   - Verify repository has Actions enabled
   - Check workflow logs for specific errors

3. **Configuration Issues**
   - Validate YAML syntax: `hawk validate config <file>.yml`
   - Check application IDs match StackHawk dashboard

### Support
- StackHawk Documentation: [docs.stackhawk.com](https://docs.stackhawk.com)
- GitHub Issues: Use this repository's Issues tab

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.
