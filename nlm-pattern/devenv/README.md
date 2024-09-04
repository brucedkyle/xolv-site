# How to copy environment variables into Jupyter Notebook

One of the ways to think about passing in secrets and tokens into a Jupyter Notebook is to use environment variables. But not all the user-created ones are made available inside your notebook.

One solution is to store secrets in a file, such as am `.env` environment file and load them from the code.

The Python module `python-dotenv` does just that. It reads key-value pairs from a `.env` file and sets them as environment variables that you can access.

Let's start by creating a project and the `.env` file with some environment variables you want to use.

## Create a project folder

Navigate to the location you want to create the project.

```bash
mkdir project
cd project
pwd
## should so the path to your project
```

## Create .env file

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

## Start Notebook from WSL command line

To start the environment. Go to your project directory:

```bash
export PYDEVD_DISABLE_FILE_VALIDATION=1 # prevents certain "frozen modules" warnings
conda env create -f environment.yml
```

## Activate the project and run Notebook

```bash
conda activate test-environment
jupyter notebook
```

## Test the variables

To see the variables in your Notebook, use the following magic command:

```python
%env
```

This shows the variables that Linux passed into the Notebook.

To load your variables, run the following cell:

```python
from dotenv import load_dotenv
load_dotenv()
```

Once your variables are loaded, you can see your environment variables using `getenv()`:

```python
import os
music_secret=os.getenv('MUSICSECRET')
music_secret
```

or using `os.environ` object.

```python
api_key=os.environ['API_KEY']
api_key
```

## Exit

Close the notebook, then 

### Deactivate

When you are done, call

```bash
conda deactivate
```

## For more information

See [python-dotevn](https://github.com/theskumar/python-dotenv) on GitHub