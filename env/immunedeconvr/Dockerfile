FROM mambaorg/micromamba:1-bookworm-slim AS base

FROM base AS build

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    cmake && \
    rm -rf /var/lib/apt/lists/*


USER $MAMBA_USER

# Copy the necessary files
COPY --chown=$MAMBA_USER:$MAMBA_USER env.yaml /tmp/env.yaml
COPY --chown=$MAMBA_USER:$MAMBA_USER install.R /tmp/install.R

# Install dependencies using micromamba and clean up
RUN micromamba install -y -n base -f /tmp/env.yaml && \
    micromamba clean --all --yes


ARG MAMBA_DOCKERFILE_ACTIVATE=1

# Run the R script
RUN Rscript /tmp/install.R && \
    rm /tmp/install.R /tmp/env.yaml

# Stage 2: Final runtime stage
FROM base

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    procps && \
    rm -rf /var/lib/apt/lists/*

USER $MAMBA_USER

ARG MAMBA_DOCKERFILE_ACTIVATE=1

# Copy the installed environment and R packages from the build stage to ensure R and Python are available
COPY --from=build /opt/conda /opt/conda

