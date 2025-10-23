# GitHub Pages Setup Instructions

This document explains how to set up GitHub Actions and GitHub Pages for automated Amtrak Live updates.

## Step 1: Enable GitHub Actions

1. Go to your repository on GitHub
2. Click on "Settings" → "Actions" → "General"
3. Under "Workflow permissions", select "Read and write permissions"
4. Check "Allow GitHub Actions to create and approve pull requests"
5. Click "Save"

## Step 2: Enable GitHub Pages

1. Go to "Settings" → "Pages"
2. Under "Build and deployment":
   - **Source**: Select "GitHub Actions"
3. Click "Save"

## Step 3: Push the Workflow Files

The following files have been created:
- `.github/workflows/update-plots.yml` - Updates train data every 3 minutes
- `.github/workflows/pages.yml` - Deploys to GitHub Pages

Push these to your repository:

```bash
git add .github/workflows/
git commit -m "Add GitHub Actions workflows"
git push origin main
```

## Step 4: GitHub Pages URL

After the first successful deployment, your API will be available at:

```
https://YOUR_USERNAME.github.io/YOUR_REPO_NAME/
```

### API Endpoints:

- Train Data: `https://YOUR_USERNAME.github.io/YOUR_REPO_NAME/api/trains.json`
- Plot Images: `https://YOUR_USERNAME.github.io/YOUR_REPO_NAME/plots/FILENAME.png`

## Step 5: Update Your Main Website

In your main website (with your custom domain), update the fetch URLs:

```javascript
// Instead of localhost or your EC2 instance:
const API_BASE = 'https://YOUR_USERNAME.github.io/YOUR_REPO_NAME';

// Fetch train data
fetch(`${API_BASE}/api/trains.json`)
  .then(res => res.json())
  .then(trains => {
    trains.forEach(train => {
      // Images are now at GitHub Pages URLs
      const foregroundImg = `${API_BASE}/${train.foreground_img}`;
      const backgroundImg = `${API_BASE}/${train.background_img}`;
      // ... rest of your code
    });
  });
```

## Step 6: Monitor Workflows

1. Go to "Actions" tab in your repository
2. You should see the "Update Amtrak Plots" workflow running every 3 minutes
3. After plots are updated, "Deploy to GitHub Pages" will run automatically

## Cron Schedule

The workflow runs every 3 minutes (`*/3 * * * *`). You can adjust this in `.github/workflows/update-plots.yml`:

- Every 3 minutes: `*/3 * * * *`
- Every 5 minutes: `*/5 * * * *`
- Every 10 minutes: `*/10 * * * *`

## CORS Configuration

All endpoints are configured with CORS headers allowing access from any domain (`Access-Control-Allow-Origin: *`), so your main website can fetch data without issues.

## Important Notes

### GitHub Actions Free Tier Limits
- 2,000 minutes/month for free accounts
- 3,000 minutes/month for Pro accounts
- Running every 3 minutes = ~14,400 runs/month
- Each run takes ~2-3 minutes
- **Estimated usage**: ~40,000-50,000 minutes/month

⚠️ **This will exceed free tier limits!** Consider:

1. **Increase interval to 5-10 minutes** to reduce costs
2. **Upgrade to GitHub Pro/Team** for more minutes
3. **Use GitHub Actions billable minutes** (~$0.008/minute)
4. **Alternative**: Use a free tier cloud service (Render, Railway, etc.)

### Recommended: 5-Minute Interval

For a better balance, edit `.github/workflows/update-plots.yml` and change:

```yaml
schedule:
  - cron: '*/5 * * * *'  # Every 5 minutes instead of 3
```

This reduces monthly runs from ~14,400 to ~8,640, cutting usage to ~20,000-25,000 minutes/month.

## Testing

To test immediately without waiting for the cron schedule:

1. Go to "Actions" tab
2. Select "Update Amtrak Plots" workflow
3. Click "Run workflow" → "Run workflow"

## Troubleshooting

### Workflow fails with permission errors
- Check that "Read and write permissions" is enabled in Settings → Actions

### GitHub Pages not updating
- Ensure GitHub Pages source is set to "GitHub Actions"
- Check the "Deploy to GitHub Pages" workflow logs

### CORS errors on your main website
- Ensure you're using the correct GitHub Pages URL
- Check browser console for specific error messages
- GitHub Pages may take a few minutes to apply CORS headers

## Repository Structure for GitHub Pages

After deployment, your GitHub Pages will serve:

```
https://YOUR_USERNAME.github.io/YOUR_REPO_NAME/
├── index.html              (API documentation)
├── api/
│   └── trains.json        (train data API endpoint)
└── plots/
    ├── main_plot_XXX.png
    ├── main_bg_plot_XXX.png
    └── ... (all plot images)
```

