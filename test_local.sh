#!/bin/bash

# Local Testing Script for Amtrak Live
# This script simulates what GitHub Actions will do

set -e  # Exit on error

echo "🚂 Amtrak Live - Local Test Runner"
echo "=================================="
echo ""

# Check dependencies
echo "📦 Checking dependencies..."

if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed"
    exit 1
fi

if ! command -v Rscript &> /dev/null; then
    echo "❌ R is not installed"
    exit 1
fi

echo "✅ Python 3: $(python3 --version)"
echo "✅ R: $(Rscript --version 2>&1 | head -n 1)"
echo ""

# Check Python packages
echo "📦 Checking Python packages..."
python3 -c "import requests" 2>/dev/null || {
    echo "❌ requests package not installed"
    echo "   Install with: pip install requests"
    exit 1
}
echo "✅ requests installed"
echo ""

# Check R packages
echo "📦 Checking R packages..."
Rscript -e "library(ggplot2); library(dplyr); library(lubridate)" 2>/dev/null || {
    echo "❌ Some R packages are missing"
    echo "   Install with: Rscript -e 'install.packages(c(\"ggplot2\", \"dplyr\", \"lubridate\", \"grid\", \"tools\"))'"
    exit 1
}
echo "✅ R packages installed"
echo ""

# Create directories
echo "📁 Creating train_data directories..."
rm -rf train_data
mkdir -p train_data/north train_data/south
echo "✅ Directories created"
echo ""

# Generate image ID
IMG_ID=$(date +"%S%M%H%d%m%Y")
echo "🎯 Image ID: $IMG_ID"
echo ""

# Collect train data
echo "🚄 Collecting train data..."
python3 data_collector.py $IMG_ID || {
    echo "❌ Data collection failed"
    exit 1
}
echo "✅ Train data collected"
echo ""

# Count CSV files
NORTH_COUNT=$(ls -1 train_data/north/*.csv 2>/dev/null | wc -l | tr -d ' ')
SOUTH_COUNT=$(ls -1 train_data/south/*.csv 2>/dev/null | wc -l | tr -d ' ')
echo "   📊 Northbound trains: $NORTH_COUNT"
echo "   📊 Southbound trains: $SOUTH_COUNT"
echo ""

# Generate plots
echo "📊 Generating plots with R..."
Rscript plot_generator.r $IMG_ID || {
    echo "❌ Plot generation failed"
    exit 1
}
echo "✅ Plots generated"
echo ""

# Update JSON
echo "📝 Updating train data JSON..."
cat new_train_img_data.json > train_img_data.json
rm new_train_img_data.json
echo "✅ JSON updated"
echo ""

# Wait a bit
echo "⏳ Waiting for plots to be written..."
sleep 2
echo ""

# Trim old plots
echo "🧹 Trimming old plots..."
python3 trim_plots.py $IMG_ID || {
    echo "❌ Plot trimming failed"
    exit 1
}
echo "✅ Old plots removed"
echo ""

# Count plots
PLOT_COUNT=$(ls -1 plots/*.png 2>/dev/null | wc -l | tr -d ' ')
echo "📈 Total plots: $PLOT_COUNT"
echo ""

# Display train data summary
echo "📋 Train Data Summary:"
echo "---"
python3 -c "
import json
with open('train_img_data.json', 'r') as f:
    trains = json.load(f)
    print(f'Total entries: {len(trains)}')
    for train in trains[:5]:  # Show first 5
        print(f'  - {train[\"id\"]}: {train[\"animation_start\"]:.1f}%')
    if len(trains) > 5:
        print(f'  ... and {len(trains) - 5} more')
"
echo ""

# Test Flask app (optional)
if [ "$1" == "--serve" ]; then
    echo "🌐 Starting Flask server..."
    echo "   Access at: http://localhost:5000"
    echo "   Press Ctrl+C to stop"
    echo ""
    python3 app.py
else
    echo "✅ All tests passed!"
    echo ""
    echo "💡 Tips:"
    echo "   - View plots in the plots/ directory"
    echo "   - Check train_img_data.json for API data"
    echo "   - Run './test_local.sh --serve' to start Flask server"
    echo "   - Run frontend with: cd frontend && npm run dev"
fi

