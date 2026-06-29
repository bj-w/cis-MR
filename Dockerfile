# R version
FROM rocker/r-ver:4.6.0

# Install curl and other linux libraries that R packages need
RUN apt-get update && apt-get install -y \
    curl \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libz-dev \
    liblzma-dev \
    libbz2-dev

# Install + set up rv
RUN curl -sSL https://raw.githubusercontent.com/A2-ai/rv/refs/heads/main/scripts/install.sh | bash

# Add ~/.local/bin to PATH and verify installation
ENV PATH="/root/.local/bin:${PATH}"
RUN which rv || (echo "rv not found, checking installation..." && \
    find /root -name "rv" -type f 2>/dev/null && \
    ls -la /root/.local/bin/)

# specify work directory
WORKDIR /project

# Copy rv metadata
COPY rproject.toml rproject.toml
COPY rv.lock rv.lock
COPY rv/scripts/ rv/scripts/

# Install all R packages
RUN rv sync

# ✅ Set library path
ENV R_LIBS_USER=/project/rv/library/4.6/x86_64/noble

# ✅ Overwrite .Rprofile — stop activate.R from running at runtime
RUN echo '.libPaths(c(Sys.getenv("R_LIBS_USER"), .libPaths()))' > /project/.Rprofile && \
    echo '.libPaths(c(Sys.getenv("R_LIBS_USER"), .libPaths()))' > /root/.Rprofile && \
    echo '.libPaths(c(Sys.getenv("R_LIBS_USER"), .libPaths()))' > /usr/local/lib/R/etc/Rprofile.site

# Default to bash terminal when running docker image
CMD ["bash"]
