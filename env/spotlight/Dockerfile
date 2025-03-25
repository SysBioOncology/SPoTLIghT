FROM python:3.8.10-slim AS pyvenv

COPY requirements.txt /tmp/requirements.txt
# Sets utf-8 encoding for Python et al
ENV LANG=C.UTF-8
# Turns off writing .pyc files; superfluous on an ephemeral container.
ENV PYTHONDONTWRITEBYTECODE=1
# Seems to speed things up
ENV PYTHONUNBUFFERED=1

# Ensures that the python and pip executables used
# in the image will be those from our virtualenv.
ENV PATH="/venv/bin:$PATH"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libgl1-mesa-glx build-essential pkg-config \
    libhdf5-dev \
    libblosc-dev && \
    rm -rf /var/lib/apt/lists/* && \
    python -m venv /venv && \
    pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir --default-timeout=900 -r /tmp/requirements.txt

FROM ubuntu:20.04 AS base
# Sets utf-8 encoding for Python et al
ENV LANG=C.UTF-8
# Turns off writing .pyc files; superfluous on an ephemeral container.
ENV PYTHONDONTWRITEBYTECODE=1
# Seems to speed things up
ENV PYTHONUNBUFFERED=1
ENV PATH="/venv/bin:$PATH"

# Install Python 3.8.10
RUN apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common procps && \
    add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get install -y python3.8 && \
    ln -s /usr/bin/python3.8 /usr/bin/python && \
    apt-get install -y --no-install-recommends python3-pip \
    openslide-tools \
    python3-openslide \
    libgl1-mesa-glx \
    python3.8-dev \  
    build-essential \
    pkg-config \
    python-dev \
    libhdf5-dev \
    libblosc-dev \
    python3.8-venv && \
    rm -rf /var/lib/apt/lists/*

# Set up python environment #

# Add nf-bin with all Python/R scripts
ENV VIRTUAL_ENV=/spotlight_venv
RUN python3 -m venv ${VIRTUAL_ENV}
ENV PATH="${VIRTUAL_ENV}/bin:$PATH"

COPY --from=pyvenv /venv/include /spotlight_venv/include
COPY --from=pyvenv /venv/lib /spotlight_venv/lib
COPY --from=pyvenv /venv/share /spotlight_venv/share
