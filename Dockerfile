# For help about how Dockerfiles work, see https://docs.docker.com/engine/reference/builder
ARG UBUNTU_VERSION=20.04
FROM ubuntu:${UBUNTU_VERSION} AS builder
# Build argument (can be changed at build time
# This argument define timezone for tzdata requierd by qp_run
ARG tz=Etc/UTC
# Install all requierd packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
# Git for download quantum package
git \
# All necessary packages to compile and run quantum package
curl wget python gfortran gcc g++ build-essential unzip liblapack-dev pkg-config autoconf zlib1g zlib1g-dev libgmp-dev
# Add user and switch to this user
RUN adduser --disabled-password --gecos '' builder
USER builder
# I don't know why but the USER environment variable is not set so I set it because it's requested for ninja
ENV USER=builder
# Go to home
WORKDIR /home/builder
# Download quantum package
RUN git clone  --depth 1 --branch 2.1.2 https://github.com/QuantumPackage/qp2
# Go to quantum package
WORKDIR /home/builder/qp2
# Configure
RUN ./configure -i all -c config/gfortran_avx.cfg
# source don't work with /bin/sh (used by the run command so I use bash)
# Compile the code to a static build
RUN ["/bin/bash", "-c", "source quantum_package.rc ; qp export_as_tgz"]

# Used to unpack QP2
FROM busybox AS unpack
WORKDIR /tmp
COPY --from=builder /home/builder/qp2/quantum_package_static.tar.gz .
RUN tar -xf quantum_package_static.tar.gz

# This image is based from Ubuntu LTS
FROM ubuntu:${UBUNTU_VERSION}
LABEL version="2.1.2" \
maintainer.name="Mickaël Véril" \
quantum_package.author.name="Anthony Scemama" \
quantum_package.url="https://quantumpackage.github.io/qp2" \
quantum_package.repo="https://github.com/QuantumPackage/qp2" \
quantum_package.demo.repo="https://github.com/mveril/qp-demo" \
laboratory.name="Laboratoire de Chimie et Physique Quantique (LCPQ)" \
laboratory.url="http://www.lcpq.ups-tlse.fr/"
# Build argument (can be changed at build time
# This argument define the user name
ARG user=user
# This argument define timezone for tzdata requierd by qp_run
ARG tz=Etc/UTC
# install manpages and other requirements to an interactive session
RUN ["/bin/sh","-c","yes | unminimize"]
# Install all requierd packages
RUN apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install \
python htop vim emacs screen tmux less wget curl tzdata man manpages-posix lsb-release \
 -y && \
apt-get autoremove && apt-get clean
# Reconfigure tzdata with the good timezone
RUN echo $tz > /etc/timezone && rm -rf /etc/localtime && echo "set mouse=" > ~/.vimrc
RUN dpkg-reconfigure -f noninteractive tzdata
# Add user and switch to this user
RUN adduser --disabled-password --gecos '' $user
USER $user
# I don't know why but the USER environment variable is not set so I set it because it's requested for ninja
ENV USER=$user
# Go to home
WORKDIR /home/$user
# Copy examples
COPY --chown=$user examples examples
# Copy unpacked QP2 static
COPY --from=unpack --chown=$user /tmp/quantum_package_static qp2
# Prepare tmux and screen to use QPSH
RUN echo "set -g default-command /home/$user/qp2/bin/qpsh" >> .tmux.conf
RUN echo "shell \"/home/$user/qp2/bin/qpsh\"" >> .screenrc
# start a qp shell when run
CMD ["./qp2/bin/qpsh"]


