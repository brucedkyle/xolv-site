#!/usr/bin/env bash
PYTHON_ENV=chatbot

export PYDEVD_DISABLE_FILE_VALIDATION=1 # prevents certain "frozen modules" warnings
conda init
conda env create --file environment.yml -n $PYTHON_ENV
conda activate $PYTHON_ENV
# jupyter notebook --port 5000 --no-browser --ip='*' --NotebookApp.token='' --NotebookApp.password=''
