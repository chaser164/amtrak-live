# 🚀 Deployment Checklist

Use this checklist to deploy Amtrak Live with GitHub Actions and GitHub Pages.

## ✅ Pre-Deployment

- [ ] Repository is pushed to GitHub
- [ ] All workflow files are committed (`.github/workflows/`)
- [ ] `requirements.txt` is present
- [ ] `train_img_data.json` exists (can be empty placeholder)
- [ ] `plots/` directory exists

## ✅ GitHub Repository Settings

### 1. Enable GitHub Actions
- [ ] Go to **Settings** → **Actions** → **General**
- [ ] Under "Workflow permissions":
  - [ ] Select **"Read and write permissions"**
  - [ ] Check **"Allow GitHub Actions to create and approve pull requests"**
- [ ] Click **Save**

### 2. Enable GitHub Pages
- [ ] Go to **Settings** → **Pages**
- [ ] Under "Build and deployment":
  - [ ] **Source**: Select **"GitHub Actions"**
- [ ] Click **Save**

## ✅ First Run

### Trigger Initial Workflow
- [ ] Go to **Actions** tab
- [ ] Click **"Update Amtrak Plots"** workflow
- [ ] Click **"Run workflow"** dropdown → **"Run workflow"** button
- [ ] Wait 2-3 minutes for completion

### Verify Deployment
- [ ] Check that workflow completed successfully (green checkmark)
- [ ] Go to **Actions** → **Deploy to GitHub Pages**
- [ ] Verify it ran after the update workflow
- [ ] Note your GitHub Pages URL: `https://YOUR_USERNAME.github.io/YOUR_REPO`

## ✅ Test API Endpoints

Replace `YOUR_USERNAME` and `YOUR_REPO` with your values:

- [ ] Test train data: `https://YOUR_USERNAME.github.io/YOUR_REPO/api/trains.json`
  - Should return JSON array of trains
- [ ] Test plot image: `https://YOUR_USERNAME.github.io/YOUR_REPO/plots/main_plot_XXX.png`
  - Should display a plot image
- [ ] Check CORS: Test fetch from browser console on different domain

## ✅ Integrate with Your Website

### Update Your Main Website Code

- [ ] Replace API endpoint URLs with GitHub Pages URL
- [ ] Update image paths to use GitHub Pages URL
- [ ] Test on your live site

Example code:
```javascript
const API_BASE = 'https://YOUR_USERNAME.github.io/YOUR_REPO';

fetch(`${API_BASE}/api/trains.json`)
  .then(res => res.json())
  .then(trains => {
    // Your rendering code
  });
```

## ✅ Monitoring

### Check Workflow Status
- [ ] Go to **Actions** tab
- [ ] Verify "Update Amtrak Plots" runs every 3 minutes
- [ ] Check for any failed runs (red X)

### Monitor Costs
- [ ] Go to **Settings** → **Billing and plans** → **Plans and usage**
- [ ] Check "Actions" usage minutes
- [ ] ⚠️ Running every 3 minutes will exceed free tier!
  - Consider changing to 5-10 minutes
  - Or upgrade to GitHub Pro/Team

## 🔧 Troubleshooting

### Workflow Permission Errors
- **Issue**: "refusing to allow a GitHub App to create or update workflow"
- **Fix**: Enable "Read and write permissions" in Actions settings

### GitHub Pages 404
- **Issue**: API endpoints return 404
- **Fix**: 
  - Check that Pages source is "GitHub Actions"
  - Wait 5 minutes after first deployment
  - Clear browser cache

### CORS Errors
- **Issue**: "Access to fetch blocked by CORS policy"
- **Fix**: 
  - Verify GitHub Pages is fully deployed
  - Check browser console for specific error
  - Try accessing API URL directly in browser first

### Plots Not Updating
- **Issue**: Old images showing on website
- **Fix**:
  - Check Actions tab for failed workflows
  - Verify workflow has write permissions
  - Check R package installation in workflow logs

### Cost Concerns
- **Issue**: Exceeding GitHub Actions free tier
- **Solution Options**:
  1. Change cron to `*/5 * * * *` (every 5 minutes) - reduces usage by 40%
  2. Change cron to `*/10 * * * *` (every 10 minutes) - reduces usage by 70%
  3. Upgrade to GitHub Pro ($4/month) for 3000 minutes
  4. Use GitHub Actions billable minutes (~$0.008/minute)

## 📊 Recommended Schedule

For balancing update frequency with cost:

```yaml
# Every 5 minutes (recommended)
schedule:
  - cron: '*/5 * * * *'
```

## 🎉 Post-Deployment

- [ ] Update your website's documentation
- [ ] Share your live site!
- [ ] Monitor for first few hours to ensure stability
- [ ] Set up any additional monitoring/alerting if desired

---

## Quick Reference

**Your GitHub Pages URL**: `https://YOUR_USERNAME.github.io/YOUR_REPO`

**API Endpoints**:
- Train Data: `/api/trains.json`
- Plot Images: `/plots/{filename}.png`

**Workflow Files**:
- `.github/workflows/update-plots.yml` - Updates every 3 minutes
- `.github/workflows/pages.yml` - Deploys to GitHub Pages

**Local Testing**:
```bash
./update.sh
python app.py
```

---

Need help? Check [GITHUB_PAGES_SETUP.md](GITHUB_PAGES_SETUP.md) for detailed instructions.

