#!/bin/bash

# Check if package name is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <package_name>"
  echo "Example: $0 ggplot2"
  exit 1
fi

# Install packages in running container
echo "Installing package: $1"
docker-compose exec rstudio Rscript -e "install.packages('$1', repos = 'https://cloud.r-project.org')"

echo "✅ Package $1 installed successfully"
