# R version
FROM rocker/r-ver:4.6.0

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libz-dev \
    liblzma-dev \
    libbz2-dev

# Install rv
RUN curl -sSL https://raw.githubusercontent.com/A2-ai/rv/refs/heads/main/scripts/install.sh | bash

# Add rv to PATH
ENV PATH="/root/.local/bin:${PATH}"

# Set working directory
WORKDIR /project

# Copy rv metadata and scripts
COPY rproject.toml rproject.toml
COPY rv.lock rv.lock
COPY rv/scripts/ rv/scripts/

# Install all R packages
RUN rv sync

# Set R library path (rv packages are here)
ENV R_LIBS_USER=/project/rv/library/4.6/x86_64/noble

# Configure R to use the rv library
RUN echo '.libPaths(c(Sys.getenv("R_LIBS_USER"), .libPaths()))' > /root/.Rprofile

CMD ["bash"]
