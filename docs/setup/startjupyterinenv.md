# Start Jupyter notebook in a Conda environment

You must run different projects on separate environments. The environments include the `conda` and `pip` packages and their dependencies.

For why, see [Why you should use a virtual environment for EVERY python project](https://towardsdatascience.com/why-you-should-use-a-virtual-environment-for-every-python-project-c17dab3b0fd0)

## Prerequisites

- Install Anaconda
- Terminal (cmd/PowerShell/bash) with the directory set to your code

## Check the list of environments

```
conda env list
```

Switching between environments works as simply as typing `conda activate [NAME]` and if done with it deactivating it (and going back to the base environment) with `conda deactivate`.

## Create environment

The following command creates an environment named `myenv` followed by a particular version of Python and the list of packages:

```bash
conda create -n myenv python=3.9 scipy=0.17.3 astroid babel
```

!!! tip "Installation" 

    Install all the programs that you want in this environment at the same time. Installing one program at a time can lead to dependency conflicts.

## Create an environment from a environment.yml file

Create the environment from a environment.yml file:

```bash
conda env create -f environment.yml
```

The name of the enironment can be in the `environment.yml` file. 

To verify that the environment was successfully created, use:

```bash
conda info --envs
```

## But what if it fails

You might face _ResolvePackageNotFound: failure_ while creating your environment.

You can add those dependencies to the `dependencies` | `pip` section in your environments.yml file.

For more details, see [Setting Up a Conda Environment in Less Than 5 Minutes](https://medium.com/swlh/setting-up-a-conda-environment-in-less-than-5-minutes-e64d8fc338e4).


## Activate environment

```bash
conda activate myenv
jupyter notebook
```

## Best practices with Conda

We recommend that you:

- Use pip only after conda
- Install as many requirements as possible with conda then use pip.
- Pip should be run with `--upgrade-strategy only-if-needed` (the default).
- Do not use pip with the `--user argument`, avoid all users installs.

Use conda environments for isolation

- Create a conda environment to isolate any changes pip makes.
- Environments take up little space thanks to hard links.

Care should be taken to avoid running pip in the root environment.

- Recreate the environment if changes are needed
- Once pip has been used, conda will be unaware of the changes.

To install additional conda packages, it is best to recreate the environment.

- Store conda and pip requirements in text files
- Package requirements can be passed to conda via the `--file` argument.

Pip accepts a list of Python packages with `-r` or `--requirements`.

Conda env will export or create environments based on a file with conda and pip requirements.

!!! tip

    You can put the pip requirements into your environment. Add `- pip:` to the dependencies followed by the list of pip packages you will need. For example:

    ```yml
    name: myenv
    channels:
        - defaults
    dependencies:
        - pandas
        - numpy
        - pip:
            - hdfs==1.90
    ```

## Set up your dockerfile

You can use your environments.yml file to build out your Docker (or Podman) container. Here is a stub for an environment:

```dockerfile
FROM continuumio/miniconda3
ADD environment.yml /tmp/environment.yml
RUN conda env create -f /tmp/environment.yml
# Pull the environment name out of the environment.yml
RUN echo "source activate $(head -1 /tmp/environment.yml | cut -d' ' -f2)" > ~/.bashrc
ENV PATH /opt/conda/envs/$(head -1 /tmp/environment.yml | cut -d' ' -f2)/bin:$PATH
```

For more information, see [Conda Environments with Docker](https://medium.com/@chadlagore/conda-environments-with-docker-82cdc9d25754).

## References

- [Managing environments](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html)
- [Setting Up a Conda Environment in Less Than 5 Minutes](https://medium.com/swlh/setting-up-a-conda-environment-in-less-than-5-minutes-e64d8fc338e4)
- [Conda Environments with Docker](https://medium.com/@chadlagore/conda-environments-with-docker-82cdc9d25754)