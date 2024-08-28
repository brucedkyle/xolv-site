# Text classification pattern

In this example, you will learn the pattern of developing a machine learning model for text classification.

## Prerequisites

This assumes you are running in WSL 2 on Windows, but should also work on x86 Linux and Macs. 

You will need:

- You'll need a GPU that supports NVIDIA's CUDA Toolkit to build the environment.
- CUDA drivers to be installed. You can run this is Google Colab or locally. 
- If you are running in a container, you will need to have installed the NVIDIA Container Toolkit.
- Anaconda with Jupyter Notebook installed.
- A Hugging Face [user access token](https://huggingface.co/docs/hub/en/security-tokens). The tutorial shows how to add it manually. However, you can store the token in a hidden location on your laptop where you will not indaventantly check it into your code repository, retrieve it, and use it in your notebook.


## To start locally

Set up your environment.

```bash
export PYDEVD_DISABLE_FILE_VALIDATION=1 # prevents certain "frozen modules" warnings in Notebooks
cd text-classification
conda env create -f environment.yml
conda activate text_classification
jupyter notebook
```

In your code, you can access the token:

```python
from transformers import AutoModel

access_token = "hf_..."

model = AutoModel.from_pretrained("private/model", token=access_token)
```

To end the environment

```bash
conda deactivate 
```

## To start with Visual Studio Code

Set up your environment.

```bash
export PYDEVD_DISABLE_FILE_VALIDATION=1 # prevents certain "frozen modules" warnings in Notebooks
cd text-classification
conda env create -f environment.yml
conda activate text_classification
code .
```

Select your environment, if needed, then open the ` ` file.
Open `` from the 

For details, see [Jupyter Notebooks in VS Code](https://code.visualstudio.com/docs/datascience/jupyter-notebooks).

## To start with a container in Podman

You will need:

- Podman installed
- Containerfile updated with a supported version.

> [!TIP] 
> You may need to update the tag for `quay.io/jupyter/pytorch-notebook` in the **Containerfile** to match the version of CUDA you installed. See [quay.io/repository/pytorch-notebook](https://quay.io/repository/jupyter/pytorch-notebook?tab=tags) for the list of current supported tags. Only the last two versions of CUDA are supported.

The following commands `build` and then `run` the container with your environment configured.

```bash
today=$(date '+%Y%m%d%H%m') 
podman build .  --format docker --tag text_classifier:$today 
podman run --device 'nvidia.com/gpu=all' -v $HOME:$HOME -it --rm -p 8888:8888 text_classifier:$today
```





## References

This example is largely based on:

- [NLP with Transformers - Notebooks](https://github.com/nlp-with-transformers/notebooks/blob/main/02_classification.ipynb)

## Book citation

```json
@book{tunstall2022natural,
  title={Natural Language Processing with Transformers: Building Language Applications with Hugging Face},
  author={Tunstall, Lewis and von Werra, Leandro and Wolf, Thomas},
  isbn={1098103246},
  url={https://books.google.ch/books?id=7hhyzgEACAAJ},
  year={2022},
  publisher={O'Reilly Media, Incorporated}
}
```