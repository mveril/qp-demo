# qp_demo
qp_demo is the component used in the [Quantum Package demo]( https://quantumpackage.github.io/qp2/page/try)
This repo contains
- `examples`: Examples included with quantum package docker image.

- `Dockerfile`: This is a multi-stage dockerfile used to create the docker image from the [Quantum Package GitHub repo](https://github.com/QuantumPackage/qp2)

There is no guarantee of success because it's use the Quantum Package ./configure tool to install third party dependencies.

- `run.sh`: run the image in the context of the demo. (With isolated network, a limited number of container and a time limit)
before the first use of run.sh `Run.sh` we must run `make network` because it use a custom network bridge to disable communication between the QP2 containers.
## What is Docker
Docker is a containerization software.
For more info about it you can consult the official [Docker documentation](https://docs.docker.com)
