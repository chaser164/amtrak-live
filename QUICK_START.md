# ⚡ Quick Start Guide

Get your Amtrak Live project running on GitHub Actions in 5 minutes!

## 🎯 Step 1: Push to GitHub (1 min)

```bash
cd /path/to/your/project
git add .
git commit -m "Add GitHub Actions automation"
git push origin main
```

## ⚙️ Step 2: Enable GitHub Actions (1 min)

1. Go to your repo on GitHub
2. **Settings** → **Actions** → **General**
3. Select **"Read and write permissions"**
4. ✅ Check **"Allow GitHub Actions to create and approve pull requests"**
5. Click **Save**

## 🌐 Step 3: Enable GitHub Pages (1 min)

1. **Settings** → **Pages**
2. **Source**: Select **"GitHub Actions"**
3. Click **Save**

## 🚀 Step 4: First Run (2 min)

1. Go to **Actions** tab
2. Click **"Update Amtrak Plots"**
3. **Run workflow** → **Run workflow**
4. Wait for green checkmark ✅

## 🎉 Step 5: Get Your URL

Your API is now live at:
```
https://YOUR_USERNAME.github.io/YOUR_REPO/api/trains.json
```

## 💻 Update Your Website

```javascript
const API_BASE = 'https://YOUR_USERNAME.github.io/YOUR_REPO';

fetch(`${API_BASE}/api/trains.json`)
  .then(res => res.json())
  .then(trains => {
    trains.forEach(train => {
      document.getElementById('plot').src = 
        `${API_BASE}/${train.foreground_img}`;
    });
  });
```

## ⏰ Schedule (Default: Every 3 Minutes)

To change the frequency, edit `.github/workflows/update-plots.yml`:

```yaml
schedule:
  - cron: '*/5 * * * *'  # Every 5 minutes
  - cron: '*/10 * * * *' # Every 10 minutes
```

## 📚 More Help

- **Detailed Setup**: `GITHUB_PAGES_SETUP.md`
- **Checklist**: `DEPLOYMENT_CHECKLIST.md`
- **Integration Example**: `INTEGRATION_EXAMPLE.html`
- **Full Summary**: `MIGRATION_SUMMARY.md`

## 🆘 Troubleshooting

**Workflow fails?**
→ Check Actions permissions in Settings

**404 on API?**
→ Wait 5 minutes, then check Pages URL in Settings → Pages

**CORS errors?**
→ Verify GitHub Pages deployed successfully

---

**That's it!** You're now running on GitHub Actions! 🚂✨

