# Dockerfile for Sekundarschulwahl Berlin Project
# Uses rocker/rstudio as base image

FROM rocker/rstudio:latest

# Set environment variables
ENV TZ=Europe/Berlin

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libssl-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libgit2-dev \
    libicu-dev \
    libx11-dev \
    libfreetype6-dev \
    libpng-dev \
    libjpeg-dev \
    libtiff5-dev \
    && rm -rf /var/lib/apt/lists/*

# Install base R packages

RUN Rscript -e 'install.packages(\"renv\", repos = \"https://cloud.r-project.org\")' && \
    Rscript -e 'install.packages(\"tidyverse\", repos = \"https://cloud.r-project.org\")' && \
    Rscript -e 'install.packages(\"sf\", repos = \"https://cloud.r-project.org\")' && \
    Rscript -e 'install.packages(\"leaflet\", repos = \"https://cloud.r-project.org\")' && \
    Rscript -e 'install.packages(\"httr\", repos = \"https://cloud.r-project.org\")' && \
    Rscript -e 'install.packages(\"htmltools\", repos = \"https://cloud.r-project.org\")' && \
    Rscript -e 'install.packages(\"rio\", repos = \"https://cloud.r-project.org\")' && \
    Rscript -e 'install.packages(\"janitor\", repos = \"https://cloud.r-project.org\")' && \
    Rscript -e 'install.packages(\"stringr\", repos = \"https://cloud.r-project.org\")'

# Copy project files
COPY . /home/rstudio/project

# Set working directory
WORKDIR /home/rstudio/project

# Set default command
CMD ["bash", "-c", "while true; do sleep 1000; done"]
