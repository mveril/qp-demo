# qp-demo
This is the component used in the [Quantum Package demo]( https://quantumpackage.github.io/qp2/page/try)

- examples: Examples included with quantum package docker image.

- Dockerfile: Create docker image from prebuild quantum package `quantum_package_static.tar.gz`. This is the image of Quantum Package demo

- Dockerfile.compile: Create docker image from the [Quantum Package GitHub repo](https://github.com/QuantumPackage/qp2).

- run.sh: run the image in the context of the demo. (With isolated network, a limited number of container and a time limit)

## What is Docker
Docker is a containerization software.
For more info about it you can cosult the official [Docker documentation](https://docs.docker.com)

## How to build the image

### Precompiled

run `make`

A tar.gz archive of quantum package is needed at the root of the project with the name `quantum_package_static.tar.gz`

This archive can be create with the command `qp_export_as_tgz` of quantum package

### Compiled from github

run `make compile`

There is no guarantee of success because it's use the Quantum Package ./configure tool to install third party dependencies.

## Before use run.sh

We must run `make network`  before the first use of run.sh because it use a custom network bridge to disable communication between QP2 containers