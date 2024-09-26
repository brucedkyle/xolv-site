#!/bin/bash
ENV_NAME="${1:-open_ai_hello_world}"
conda env create -f environment.yml -n $ENV_NAME
conda activate $ENV_NAME
jupyter notebook