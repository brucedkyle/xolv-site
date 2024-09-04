# Prototype Jupyter notebook

This folder provides for a sample starting point for your Jupyter Notebook.

## Features

When you have walked through the steps, the prototype will have been set up for your development and include the following features:

- A Conda environment
- A Containerfile for Podman
- Support for local GPU

## Prerequisites

You will need:

- To have Git enabled for your project
- [Conda](https://www.anaconda.com/products/distribution) or [miniconda](https://docs.anaconda.com/miniconda/#quick-command-line-install) installed
- Set up your development computer for using its NVIDIA GPU. See [Install NVIDIA GPU display driver](/ai-ml-datascience/gpu/setupnvidiadriver/)
- [PyTorch](https://pytorch.org/get-started/locally/) installed that matches your hardware.
- An NVIDIA or AMD GPU in order to harness the full power of PyTorch’s CUDA support or ROCm support. This article describes how to enable your NVIDIA GPU.  

To run in a container on your GPU, you will need:

- [Podman](https://podman.io/docs/installation) installed
- [How to set up GPU development for containers with Podman](https://www.xolv.info/ai-ml-datascience/gpu/setupmlonwindows/)

To test your CUDA environment:

```bash
nvcc --version
```
and
```bash
nvidia-smi
```
and
```
nvidia-smi --list-gpus
```

To see something similar to:

```text
GPU 0: NVIDIA GeForce RTX 3060 Laptop GPU (UUID: GPU-fbeb177f-f196-93e0-b215-12b7c899dc82)
```

## Set it up

The set up takes a few steps.

1. Create a project folder
2. Create an `.env` file with the environment variables you want to use in your Notebook.
3. Update your `environment.yml` file with your packages, both Conda and PIP.
4. Start your notebook
5. As you run your notebook, you may need to update the environment with new packages or updated packages.
6. When you are done, `deactivate` the environment.

### Create a project folder

Navigate to the location you want to create the project.

```bash
mkdir project
cd project
pwd
## should so the path to your project
```

### Create .env file

You will need a file named `.env` at the root node of the project to store your secrets, your API keys, and database passwords.

To create the `env` file, create it and add your API keys as needed. For example, from the root of your project folder:

```sh
cat > .env <<EOF
#!/bin/bash  
#filename: .env
MUSICSECRET=polkalover 
API_KEY=1168310b-577e-451c-aca0-4e3470f86488
EOF
```

> [!IMPORTANT]
> Your `.gitignore` file should include `.env` in its list of files not to check in.

### Update your environment.yml file

Update `environment.yml` to match your project as needed, especially the project name.

## Start Notebook from WSL command line

To start the environment. Go to your project directory:

```bash
export PYDEVD_DISABLE_FILE_VALIDATION=1 # prevents certain "frozen modules" warnings
conda env create -f environment.yml
```

Verify that the environment was created:

```bash
conda info --envs
```

### Activate the project and run Notebook

```bash
conda activate project
```

### Test the CUDA environment

Run `cuda_test.py` from the command line.

```bash
python ./cuda_test.py
```

### Run the notebook
```
jupyter notebook
```

### Update environment

You may find that:

- One of your core dependencies just released a new version (dependency version number update).
- You need an additional package for data analysis (add a new dependency).
- You found a better package and no longer need the older package (add new dependency and remove old dependency).

Update your `environment.yml` file as needed.

```bash
# conda activate project if needed
conda env update --file environment.yml --prune
```

`-prune` causes conda to remove any dependencies that are no longer required from the environment.

### Share environment

To share your exact environment, you need to save off your packages and their current versions:


Once you are completed, you may want to save out the exact versions of the packages you are using in your project. To export your environment:

```bash
conda env export --no-builds > environment.yml 
```
<!--
TODO Update PIP
-->

### Deactivate

When you are done, call

```bash
conda deactivate
```
<!--
## Start Notebook in Podman
TODO
-->

## References

- [Managing environments](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html)