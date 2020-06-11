# For help about how Dockerfiles work, see https://docs.docker.com/engine/reference/builder

# This image is based from Ubuntu LTS
FROM ubuntu:20.04
LABEL version="1.0" \
maintainer.name="Mickaël Véril" \
quantum_package.author.name="Anthony Scemama" \
quantum_package.url="https://quantumpackage.github.io/qp2" \
quantum_package.repo="https://github.com/QuantumPackage/qp2" \
quantum_package.demo.repo="https://github.com/mveril/qp-demo"
laboratory.name="Laboratoire de Chimie et Physique Quantique (LCPQ)" \
laboratory.url="http://www.lcpq.ups-tlse.fr/"
# Build argument (can be changed at build time
# This argument define the user name
ARG user=user
# This argument define timezone for tzdata requierd by qp_run
ARG tz=Etc/UTC
# Enable manpages installation
RUN sed -i 's,^path-exclude=/usr/share/man/,#path-exclude=/usr/share/man/,' /etc/dpkg/dpkg.cfg.d/excludes
# Install all requierd packages
RUN apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install \
python htop vim emacs screen tmux less wget curl tzdata man manpages-posix lsb-release \
 -y && \
apt-get autoremove && apt-get clean
# Reconfigure tzdata with the good timezone
RUN echo $tz > /etc/timezone && rm -rf /etc/localtime && echo "set mouse=" > ~/.vimrc
RUN dpkg-reconfigure -f noninteractive tzdata
# ADD user and switch to this user
RUN adduser --disabled-password --gecos '' $user
USER $user
# I don't know why but the USER environment variable is not set so I set it because it's requested for ninja
ENV USER=$user
# Go to home
WORKDIR /home/$user
# untar directly static quantum package
ADD quantum_package_static.tar.gz .
# move quantum package
RUN mv quantum_package_static qp2
# add examples
COPY --chown=$user  examples examples
RUN echo "set -g default-command /home/$user/qp2/bin/qpsh" >> .tmux.conf
RUN echo "shell \"/home/$user/qp2/bin/qpsh\"" >> .screenrc
# start a qp shell when run
CMD ["./qp2/bin/qpsh"]


