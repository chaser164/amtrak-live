#!/bin/bash

# ⚠️ DEPRECATED: This script is now replaced by GitHub Actions
# See .github/workflows/update-plots.yml for the automated version
# For local testing, use: ./test_local.sh

LOCKFILE="/tmp/marey_update.lock"

# Check if the lock file exists
if [ -e "$LOCKFILE" ]; then
    echo "Script is already running. Exiting."
    exit 1
fi

cd /home/ec2-user/amtrak-live

# Create the lock file
touch "$LOCKFILE"

# Ensure the lock file is removed on script exit or termination
trap "rm -f $LOCKFILE" EXIT

img_id=$(date +"%S%M%H%d%m%Y")
rm -rf train_data
mkdir train_data
mkdir train_data/north train_data/south
/home/ec2-user/amtrak-live/.venv/bin/python3 data_collector.py $img_id
Rscript plot_generator.r $img_id
cat new_train_img_data.json > train_img_data.json
rm new_train_img_data.json
sleep 30
/home/ec2-user/amtrak-live/.venv/bin/python3 trim_plots.py $img_id
unset img_id
