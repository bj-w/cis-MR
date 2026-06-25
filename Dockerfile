# R version
FROM rocker/r-ver:4.6.0

# Install some linux libraries that R packages need
RUN apt-get update && apt-get install -y libcurl4-openssl-dev libssl-dev libxml2-dev libz-dev liblzma-dev libbz2-dev

# Install renv
RUN Rscript -e "install.packages('remotes', repos = c(CRAN = 'https://cloud.r-project.org'))"
RUN Rscript -e "remotes::install_github('rstudio/renv@v1.2.3')"

# Create a directory named after our project directory
WORKDIR /workdir

# Copy the lockfile over to the Docker image
COPY renv.lock renv.lock

# Install all R packages specified in renv.lock
RUN Rscript -e 'renv::restore()'

# Default to bash terminal when running docker image
CMD ["bash"]
