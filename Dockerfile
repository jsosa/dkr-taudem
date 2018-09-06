FROM debian:latest

MAINTAINER Jeison Sosa <j.sosa@bristol.ac.uk>

# Dockerfile adapted from:
# https://github.com/WikiWatershed/docker-taudem/blob/master/Dockerfile
# https://github.com/ContinuumIO/docker-images/blob/master/miniconda3/Dockerfile

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV GDAL_VERSION 2.1.0
ENV OPEN_MPI_SHORT_VERSION 1.8
ENV OPEN_MPI_VERSION 1.8.1
ENV TAUDEM_VERSION 5.3.8
ENV PATH /opt/conda/bin:$PATH
ENV PATH /opt/taudem:$PATH

RUN apt-get update --fix-missing && \
    apt-get install -y \
    build-essential \
    g++ \
    gfortran \
    python-all-dev \
    python-pip \
    python-numpy \
    libblas-dev \
    liblapack-dev \
    libgeos-dev \
    libproj-dev \
    libspatialite-dev \
    libspatialite7 \
    spatialite-bin \
    libibnetdisc-dev \
    wget \
    bzip2 \
    ca-certificates \
    curl \
    git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget -qO- http://download.osgeo.org/gdal/${GDAL_VERSION}/gdal-${GDAL_VERSION}.tar.gz | tar -xzC /usr/src && \
    cd /usr/src/gdal-${GDAL_VERSION} && \
    ./configure --with-python --with-spatialite && \
    make install

RUN wget -qO- https://www.open-mpi.org/software/ompi/v${OPEN_MPI_SHORT_VERSION}/downloads/openmpi-${OPEN_MPI_VERSION}.tar.gz | tar -xzC /usr/src && \
    cd /usr/src/openmpi-${OPEN_MPI_VERSION} && \
    ./configure && \
    make install && \
    ldconfig

RUN wget -qO- https://github.com/dtarb/TauDEM/archive/v${TAUDEM_VERSION}.tar.gz | tar -xzC /usr/src && \
    rm -rf /usr/src/TauDEM-${TAUDEM_VERSION}/TestSuite && \
    cd /usr/src/TauDEM-${TAUDEM_VERSION}/src && \
    make && \
    ln -s /usr/src/TauDEM-${TAUDEM_VERSION} /opt/taudem

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-4.5.4-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

ENV TINI_VERSION v0.16.1
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/bin/bash" ]
