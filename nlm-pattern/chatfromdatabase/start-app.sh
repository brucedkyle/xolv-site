#!/bin/bash
ENV_NAME="${1:-chatfromdb}"
source activate base
conda env create -f environment.yml -n $ENV_NAME
conda activate $ENV_NAME