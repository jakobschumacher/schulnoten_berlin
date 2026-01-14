FROM rocker/rstudio:4.4

# Install system libraries required by spatial/tidy packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    libudunits2-dev \
    libgdal-dev \
    libgeos-dev \
    libproj-dev \
    libsodium-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libharfbuzz-dev \
    libfribidi-dev \
 && rm -rf /var/lib/apt/lists/*

# Relax compiler flags for packages that fail with -Werror=format-security
RUN mkdir -p /root/.R /home/rstudio/.R && \
    cat <<'EOF' | tee /root/.R/Makevars >/home/rstudio/.R/Makevars
CPPFLAGS += -Wno-error=format-security -Wno-format-security
CFLAGS += -Wno-error=format-security -Wno-format-security
CXXFLAGS += -Wno-error=format-security -Wno-format-security
EOF
RUN chown -R rstudio:rstudio /home/rstudio/.R

# Install renv
RUN R -e "install.packages('renv', repos = 'https://cloud.r-project.org')"

# Set project dir
WORKDIR /project

# Copy renv files first (for layer caching)
COPY renv.lock renv.lock
COPY renv/activate.R renv/activate.R
# Copy settings if available
COPY renv/settings.json renv/settings.json

# Restore packages to project library (fast on rebuilds)
RUN R -e "options(renv.settings.cache.enabled = FALSE); renv::restore()"

# Copy rest of project
COPY . .

# Expose port
EXPOSE 8787
