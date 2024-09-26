# About Jupyter Docker Stacks

[Jupyter Docker Stacks](https://jupyter-docker-stacks.readthedocs.io/en/latest/index.html) are a set of ready-to-run Docker images containing Jupyter applications and interactive computing tools. You can use a stack image to do any of the following (and more):

- Start a personal Jupyter Server with the JupyterLab frontend (default)
- Run JupyterLab for a team using JupyterHub
- Start a personal Jupyter Server with the Jupyter Notebook frontend in a local Docker container
- Write your own project Dockerfile

!!! important

    Images hosted on Docker Hub are no longer updated. Use [quay.io image](https://quay.io/organization/jupyter).

## Where to find

All Jupyter Docker Stack images are available on [Quay.io registry](https://quay.io/organization/jupyter). We provide CUDA accelerated versions of images are available for tensorflow-notebook and pytorch-notebook.

To use such an image, you have to specify a special prefix tag to the image: versioned CUDA prefix like `cuda11-` or `cuda12-` for `pytorch-notebook` or just `cuda-` for `tensorflow-notebook`.

## Run images

You will need:

- a  compatible NVIDIA GPU
- NVIDIA Linux driver installed
- add `--gpus all` (or `--gpus '"device=all"'`) flag to if you’re using Docker
add `--device 'nvidia.com/gpu=all'` flag if you’re using Podman

You can also enable GPU support on Windows using [Docker](https://docs.docker.com/desktop/gpu/) or [Podman](https://github.com/containers/podman/issues/19005).



## Core stacks

- [CUDA enabled variant](https://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html#cuda-enabled-variant)
- [jupyter/docker-stacks-foundation](https://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html#cuda-enabled-variant)
- [jupyter/base-notebook](https://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html#jupyter-base-notebook)
- [jupyter/minimal-notebook](https://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html#jupyter-minimal-notebook)
- [jupyter/r-notebook](https://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html#jupyter-minimal-notebook)
- [jupyter/julia-notebook](https://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html#jupyter-julia-notebook)
- [jupyter/scipy-notebook](https://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html#jupyter-scipy-notebook)
- [jupyter/tensorflow-notebook](https://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html#jupyter-tensorflow-notebook)
- [jupyter/pytorch-notebook](https://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html#jupyter-pytorch-notebook)
- [jupyter/datascience-notebook](https://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html#jupyter-datascience-notebook)
- [jupyter/pyspark-notebook](https://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html#jupyter-pyspark-notebook)
- [jupyter/all-spark-notebook](https://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html#jupyter-all-spark-notebook)

Source code for all of the notebooks are available on Github [docker-stacks](https://github.com/jupyter/docker-stacks/tree/main)

## Running on OpenShift

Examples provides templates for deploying the Jupyter Project docker-stacks images to OpenShift.

See [OpenShift example](https://github.com/jupyter/docker-stacks/tree/main/examples/openshift).

## Source to image

[Source-to-Image (S2I)](https://github.com/openshift/source-to-image) is an open source project which provides a tool for creating container images. It works by taking a base image, injecting additional source code or files into a running container created from the base image, and running a builder script in the container to process the source code or files to prepare the new image.

## Reference

- [Juptyer Docker Stacks](https://jupyter-docker-stacks.readthedocs.io/en/latest/index.html)
- [CUDA enabled Jupyter Docker Image](https://blog.jupyter.org/cuda-enabled-jupyter-docker-images-8a9f8b8f2158)