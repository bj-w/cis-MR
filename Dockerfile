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
WORKDIR /workdir

# Sync rv environment
COPY rproject.toml rproject.toml
COPY rv.lock rv.lock
RUN rv sync
RUN rv activate

# Default to bash terminal when running docker image
CMD ["bash"]
