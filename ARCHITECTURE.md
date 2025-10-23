# 🏗️ Architecture Overview

## System Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        GitHub Actions                           │
│                    (Runs every 3 minutes)                       │
│                                                                 │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐    │
│  │  Amtracker   │───▶│ data_        │───▶│ plot_        │    │
│  │  API (v3)    │    │ collector.py │    │ generator.r  │    │
│  └──────────────┘    └──────────────┘    └──────────────┘    │
│                             │                     │            │
│                             ▼                     ▼            │
│                      ┌────────────────────────────────┐        │
│                      │   CSV Files (train_data/)      │        │
│                      │   - north/*.csv                │        │
│                      │   - south/*.csv                │        │
│                      └────────────────────────────────┘        │
│                             │                     │            │
│                             ▼                     ▼            │
│                      ┌────────────────────────────────┐        │
│                      │  Plots (plots/)                │        │
│                      │  - *_plot_*.png (foreground)   │        │
│                      │  - *_bg_plot_*.png (background)│        │
│                      └────────────────────────────────┘        │
│                             │                     │            │
│                             ▼                     ▼            │
│                      ┌────────────────────────────────┐        │
│                      │  train_img_data.json           │        │
│                      │  (API manifest)                │        │
│                      └────────────────────────────────┘        │
│                                    │                           │
└────────────────────────────────────┼───────────────────────────┘
                                     │
                                     │ git push
                                     ▼
                          ┌──────────────────────┐
                          │   GitHub Repository  │
                          │   (main branch)      │
                          └──────────────────────┘
                                     │
                                     │ triggers
                                     ▼
                          ┌──────────────────────┐
                          │  GitHub Pages Deploy │
                          │  (pages.yml)         │
                          └──────────────────────┘
                                     │
                                     ▼
┌────────────────────────────────────────────────────────────────┐
│                        GitHub Pages                            │
│             https://username.github.io/repo                    │
│                                                                │
│  /api/trains.json     ◀─── Train data API endpoint            │
│  /plots/*.png         ◀─── Plot images (CDN-cached)           │
│  /index.html          ◀─── API documentation                  │
│                                                                │
│  CORS: *              ◀─── Accessible from any domain         │
└────────────────────────────────────────────────────────────────┘
                                     │
                    ┌────────────────┼────────────────┐
                    │                │                │
                    ▼                ▼                ▼
         ┌─────────────────┐  ┌─────────────────┐  ┌────────────────┐
         │ Your Website    │  │ Mobile Apps     │  │ Other Clients  │
         │ (Custom Domain) │  │                 │  │                │
         └─────────────────┘  └─────────────────┘  └────────────────┘
```

## Component Breakdown

### 1. Data Collection (`data_collector.py`)
**Purpose**: Fetch real-time train data from Amtracker API

**Input**: 
- Amtracker API endpoint
- Image ID (timestamp)

**Output**:
- CSV files for each train (north/south directories)
- `new_train_img_data.json` (manifest)

**Runs**: Every 3 minutes via GitHub Actions

### 2. Plot Generation (`plot_generator.r`)
**Purpose**: Create Marey-style train schedule visualizations

**Input**:
- CSV files from `train_data/`
- Image ID
- Station data

**Output**:
- Foreground plots (current train progress)
- Background plots (full schedule)
- Main, North, South, and individual train plots

**Technology**: R with ggplot2

### 3. Plot Cleanup (`trim_plots.py`)
**Purpose**: Remove old plot files to save space

**Input**: Image ID

**Output**: Only keeps plots with current Image ID

**Runs**: After plot generation

### 4. GitHub Actions Workflows

#### `update-plots.yml`
- **Trigger**: Cron schedule (`*/3 * * * *`)
- **Duration**: ~2-3 minutes per run
- **Actions**:
  1. Install Python + R dependencies
  2. Run data collection
  3. Generate plots
  4. Trim old files
  5. Commit and push changes

#### `pages.yml`
- **Trigger**: Push to main (plots or JSON changes)
- **Duration**: ~30-60 seconds
- **Actions**:
  1. Create public directory structure
  2. Copy plots and JSON
  3. Deploy to GitHub Pages

### 5. GitHub Pages
**Purpose**: Static hosting with CDN

**Structure**:
```
public/
├── index.html          # API documentation
├── api/
│   └── trains.json     # Train data endpoint
└── plots/
    ├── main_plot_*.png
    ├── north_plot_*.png
    ├── south_plot_*.png
    └── [train]_plot_*.png
```

**Features**:
- CORS enabled for all endpoints
- Global CDN distribution
- HTTPS by default
- No server maintenance

### 6. Your Website Integration
**Purpose**: Display live train data

**Method**: Fetch JSON from GitHub Pages, display images

```javascript
fetch('https://username.github.io/repo/api/trains.json')
  .then(res => res.json())
  .then(trains => {
    // Render train visualizations
  });
```

## Data Flow Timeline

```
00:00 → GitHub Actions triggered (cron)
00:01 → Python collects train data from Amtracker
00:02 → R generates plots from CSV data
00:03 → Old plots trimmed
00:04 → Changes committed and pushed
00:05 → Pages deployment triggered
00:06 → Your website fetches new data
```

## Update Frequency

**Default**: Every 3 minutes (480 updates/day)

**Configurable**:
- 3 minutes: Near real-time, high cost (~$300/month)
- 5 minutes: Good balance (~$150-200/month)
- 10 minutes: Budget-friendly (~$75-100/month)

## Advantages vs EC2

| Aspect | EC2 (Old) | GitHub Actions (New) |
|--------|-----------|---------------------|
| Setup | Complex (SSH, cron, nginx) | Simple (push code) |
| Maintenance | Regular updates needed | Fully managed |
| Scaling | Manual | Automatic |
| Monitoring | Manual | Built-in logs |
| Rollback | Complex | One-click revert |
| Cost | $5-20/month fixed | $0-300/month variable |
| CORS | Manual configuration | Built-in |
| CDN | Need CloudFront | Included free |
| HTTPS | Need cert management | Automatic |

## Security Features

1. **No API keys needed** - Amtracker API is public
2. **Read-only data** - No write access to external APIs
3. **Isolated execution** - Each run in fresh container
4. **Audit trail** - Full git history of all changes
5. **Secrets support** - If needed for future expansion

## Scalability

**Current**: ~30 trains, ~60 plots per update

**Can handle**:
- 100+ trains
- 200+ plots
- Multiple routes
- High-resolution images

**Limitations**:
- GitHub Actions timeout: 6 hours per run
- Repository size: 100GB max
- Pages size: 1GB max (automatically managed by trim_plots.py)

## Monitoring

**GitHub Actions**:
- View runs in Actions tab
- Email notifications on failure
- Detailed logs for debugging

**GitHub Pages**:
- Deployment history in Pages settings
- Live URL status
- Traffic analytics (if enabled)

## Disaster Recovery

**Automatic backups**: Git history contains all data

**Recovery steps**:
1. Identify last working commit
2. `git revert` or `git reset` to that commit
3. Push to trigger redeployment
4. System restored in ~5 minutes

## Future Enhancements

Possible additions:
- Multiple routes (not just NEC)
- Historical data analysis
- Performance metrics
- Custom alert system
- Mobile-optimized API
- WebSocket live updates
- Railway status integration

---

**Questions about the architecture?** Check the other documentation files or GitHub Actions logs.

