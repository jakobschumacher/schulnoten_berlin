# Docker Setup for Sekundarschulwahl Berlin Project

This document explains how to use Docker with this project for consistent, reproducible R environments.

## 🐳 Prerequisites

1. **Docker installed** on your system
2. **Docker Compose** installed (usually comes with Docker)

### Install Docker

#### Ubuntu/Debian:
```bash
sudo apt-get update
sudo apt-get install docker.io docker-compose
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER
newgrp docker  # Refresh group membership
```

#### Check installation:
```bash
docker --version
docker-compose --version
```

## 🚀 Quick Start

### 1. Start the environment
```bash
cd /path/to/your/project
docker-compose up -d
```

### 2. Access RStudio
Open your web browser to: `http://localhost:8787`

**Login credentials:**
- **Username:** `rstudio`
- **Password:** None (authentication is disabled by default)

### 3. Work on your project
- Your project files are mounted at `/home/rstudio/project`
- All changes are saved to your host machine automatically
- R packages are cached in volumes for faster startup

### 4. Stop the environment
```bash
docker-compose down
```

### Access Information

When you start the container, RStudio will be available at:

**Primary URL:** `http://localhost:8787`

**Alternative URL:** `http://<container_ip>:8787` (find with `docker inspect`)

**Credentials:**
- Username: `rstudio`
- Password: None (authentication disabled)

**Quick Access Script:**
```bash
# Create a helper script
echo '#!/bin/bash
echo "RStudio is available at:"
echo "→ http://localhost:8787"
echo "→ http://$(docker inspect -f "{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}" sekundarschulwahl_rstudio):8787"
' > show_rstudio_url.sh
chmod +x show_rstudio_url.sh
```

## 📋 Configuration

### Environment Variables

Create a `.env` file in your project root:

```env
# RStudio password (leave empty to disable authentication)
RSTUDIO_PASSWORD=

# Authentication is disabled by default
DISABLE_AUTH=true

# Database password (if you add a database later)
# DB_PASSWORD=your_db_password
```

**⚠️ Important:** The `.env` file is in `.gitignore` - don't commit it!

### Package Management

This setup includes common R packages in the Docker image:
- renv
- dplyr
- sf
- leaflet
- leaflet.extras
- htr
- htmltools
- rio
- janitor
- stringr

#### Install Additional Packages

```bash
# Install a single package
docker-compose exec rstudio Rscript -e 'install.packages("package_name", repos = "https://cloud.r-project.org")'

# Install multiple packages
docker-compose exec rstudio Rscript -e 'install.packages(c("ggplot2", "dplyr"), repos = "https://cloud.r-project.org")'

# Use the helper script
./install_packages.sh package_name
```

#### Using renv

```bash
# Initialize renv
docker-compose exec rstudio Rscript -e 'renv::init()'

# Install packages
docker-compose exec rstudio Rscript -e 'renv::install("package_name")'

# Create snapshot
docker-compose exec rstudio Rscript -e 'renv::snapshot()'

# Restore packages
docker-compose exec rstudio Rscript -e 'renv::restore()'
```

### Customizing the Setup

Edit `docker-compose.yml` to:
- Change ports
- Add more volumes
- Adjust resource limits
- Add additional services

## 🔧 Common Commands

### Start services
```bash
docker-compose up -d
```

### Stop services
```bash
docker-compose down
```

### View logs
```bash
docker-compose logs -f
```

### Rebuild (if you change the compose file)
```bash
docker-compose up -d --build
```

### Clean up unused containers and volumes
```bash
docker system prune
```

## 📝 Project Structure

```
2023_10_18_Sekundarschulwahl_Berlin/
├── docker-compose.yml      # Docker configuration
├── .env                    # Environment variables (not committed)
├── README_DOCKER.md        # This file
├── data/                   # Your data files
├── index.Rmd               # Your main RMarkdown file
├── get_data.R              # Data loading functions
└── ...                     # Other project files
```

## 🎯 Volumes Explained

### `rstudio_cache`
- Stores R environment settings
- Preserves your workspace between sessions
- Located at `/home/rstudio/.R` in the container

### `rstudio_libs`
- Caches installed R packages
- Saves time on startup
- Located at `/home/rstudio/R/x86_64-pc-linux-gnu-library`

### Project Volume
- Your entire project directory is mounted
- Changes are immediate and persistent
- No need to manually copy files

## 🔄 Development Workflow

### Typical Session

1. **Start environment:**
   ```bash
   docker-compose up -d
   ```

2. **Work in RStudio:**
   - Edit files in `/home/rstudio/project`
   - Install packages (they'll be cached)
   - Render your RMarkdown documents

3. **Stop when done:**
   ```bash
   docker-compose down
   ```

### Updating Dependencies

If you need new R packages:
1. Start the environment
2. Install packages in RStudio
3. They'll be saved in the `rstudio_libs` volume
4. Next startup will be faster

## 📊 Adding More Services

### Example: Adding a Database

```yaml
services:
  database:
    image: postgres:13
    environment:
      POSTGRES_PASSWORD: ${DB_PASSWORD:-secret}
      POSTGRES_DB: school_data
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - project_network

volumes:
  postgres_data:
```

Then update your `.env`:
```env
DB_PASSWORD=your_db_password
```

### Example: Adding Shiny Apps

```yaml
services:
  shiny:
    image: rocker/shiny:latest
    ports:
      - "3838:3838"
    volumes:
      - ./shiny_apps:/srv/shiny-server
    networks:
      - project_network
```

## 🛠️ Troubleshooting

### Port already in use
```bash
# Find what's using the port
sudo lsof -i :8787

# Kill the process
sudo kill -9 <PID>

# Or use a different port
# Edit docker-compose.yml and change "8787:8787" to "8788:8787"
```

### Permission issues
```bash
# Make sure your user can access Docker
sudo usermod -aG docker $USER
newgrp docker
```

### Container won't start
```bash
# Check logs
docker-compose logs

# Remove and recreate
docker-compose down
docker-compose up -d
```

## 🎉 Benefits of This Setup

1. **Consistent environment** - Same setup for all team members
2. **No system conflicts** - Everything runs in isolation
3. **Easy setup** - No complex installation instructions
4. **Reproducible** - Works on any machine with Docker
5. **Scalable** - Easy to add more services as needed
6. **Production-ready** - Same setup can be used in production

## 📚 Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Rocker Project (R Docker images)](https://rocker-project.org/)

---

**Tip:** Keep your `.env` file secure and don't commit it to version control!
