# Amtrak Live

Welcome to [amtraklive.com](https://amtraklive.com/), the website that visualizes the current state of Amtrak's northeast corridor in the style of [E.J. Marey's Paris to Lyon train plot](https://www.researchgate.net/figure/Graphical-train-schedule-E-J-Mareys-1878-graphical-train-schedule-showing-all_fig9_332643897).

Built with R, Python, and React.

This website is a final project for *Political Science 349: Visualization of Political and Social Data* taught by Professor Alexander Coppock at Yale.

## 🚀 Automated Updates via GitHub Actions

This project uses GitHub Actions to automatically:
- Fetch live train data every 3 minutes
- Generate Marey-style plots with R
- Deploy to GitHub Pages for easy integration

### Quick Start

1. **Enable GitHub Actions** - See [GITHUB_PAGES_SETUP.md](GITHUB_PAGES_SETUP.md) for detailed instructions
2. **Set up GitHub Pages** - Configure in repository settings
3. **Access the API** - Data available at `https://YOUR_USERNAME.github.io/YOUR_REPO/api/trains.json`

### Integration

To integrate into your own website:

```javascript
const API_BASE = 'https://YOUR_USERNAME.github.io/YOUR_REPO';

fetch(`${API_BASE}/api/trains.json`)
  .then(res => res.json())
  .then(trains => {
    // Use train data and plot images
    trains.forEach(train => {
      console.log(train.id, train.foreground_img, train.background_img);
    });
  });
```

See [INTEGRATION_EXAMPLE.html](INTEGRATION_EXAMPLE.html) for a complete example.

## 📂 Project Structure

- `data_collector.py` - Fetches live train data from Amtracker API
- `plot_generator.r` - Generates Marey-style plots with ggplot2
- `trim_plots.py` - Cleans up old plot files
- `.github/workflows/` - GitHub Actions automation
  - `update-plots.yml` - Updates train data every 3 minutes
  - `pages.yml` - Deploys to GitHub Pages
- `frontend/` - React frontend (optional local development)

## 🛠️ Local Development

### Prerequisites

- Python 3.11+
- R 4.3+
- Node.js (for frontend)

### Setup

```bash
# Install Python dependencies
pip install -r requirements.txt

# Install R packages
Rscript -e 'install.packages(c("ggplot2", "dplyr", "lubridate", "grid", "tools"))'

# Run data collection and plot generation
./update.sh

# Start local Flask server (optional)
python app.py

# Start frontend dev server (optional)
cd frontend
npm install
npm run dev
```

## 📊 How It Works

1. **Data Collection** (`data_collector.py`)
   - Fetches real-time train data from Amtracker v3 API
   - Filters for Acela and Northeast Regional trains
   - Generates CSV files for each active train
   - Creates JSON manifest with train metadata

2. **Plot Generation** (`plot_generator.r`)
   - Reads train CSVs
   - Creates Marey-style plots showing:
     - Scheduled routes (dashed lines)
     - Actual routes (solid lines)
     - Current train position (vertical line)
   - Generates both background (full schedule) and foreground (current progress) plots
   - Creates aggregate plots (All Trains, Northbound, Southbound) and individual train plots

3. **Automation** (GitHub Actions)
   - Runs every 3 minutes via cron schedule
   - Commits new plots and JSON data
   - Deploys to GitHub Pages automatically

## 🌐 API Endpoints

When deployed to GitHub Pages:

- `GET /api/trains.json` - Returns array of train objects with plot URLs
- `GET /plots/{filename}.png` - Access individual plot images

All endpoints support CORS for cross-origin access.

## 📝 Resources

- [v3 Amtracker API](https://github.com/piemadd/amtrak)
- [Timetables for station distances](https://www.narprail.org/site/assets/files/20928/nec-bos-was-1.pdf)
- [E.J. Marey's Train Schedule](https://www.researchgate.net/figure/Graphical-train-schedule-E-J-Mareys-1878-graphical-train-schedule-showing-all_fig9_332643897)

## 📄 License

See [LICENSE](LICENSE) for details.