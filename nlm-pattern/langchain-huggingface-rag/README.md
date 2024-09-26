# RAG with LangChain and Hugging Face

This is an implementation to run on your local development environnment (and in a future version deploy as a container).

## Prerequisites

- LangChain API KEY
- Hugging Face API key

## Get started

### Create .env file

You will need a file named `.env` at the root node of the project to store your secrets, your API keys, and database passwords.

To create the `env` file, create it and add your API keys as needed. For example, from the root of your project folder:

```sh
cat > .env <<EOF
#!/bin/bash  
#filename: .env
OPENAI_API_KEY=1168310b-577e-451c-aca0-4e3470f86488
EOF
```

Replace the guid with your actual key. 

> [!IMPORTANT]
> Your `.gitignore` file should include `.env` in its list of files not to check in.

## Import and check CUDA

```
import torch
device = "cuda" if torch.cuda.is_available() else "cpu"
print("Using device:", device)
```

## Document loading

## Document transfomers

Text splitters and text embedding

## Vector store

## Prepare the LLM model

## Retrievers and retrieval QA chain



## References

- [Implementing RAG with Langchain and Hugging Face](https://medium.com/@akriti.upadhyay/implementing-rag-with-langchain-and-hugging-face-28e3ea66c5f7)
- [Hugging Face RAG](https://huggingface.co/docs/transformers/model_doc/rag)