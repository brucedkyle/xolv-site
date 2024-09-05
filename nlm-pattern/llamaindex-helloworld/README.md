# Bring your own data with LlamaIndex

[LlamaIndex](https://docs.llamaindex.ai/en/stable/) is a framework for building context-augmented generative AI applications with large language models including [agents](https://docs.llamaindex.ai/en/stable/understanding/agent/basic_agent/) and [workflows](https://docs.llamaindex.ai/en/stable/understanding/workflows/).

In this example, you will use the HuggingFace model locally using Python. 

> [!NOTE]
> To run locally, you will need 32gig of RAM. As an alternative, see [Starter Tutorial (OpenAI)](https://docs.llamaindex.ai/en/stable/getting_started/starter_example/)

## Use cases

Some popular use cases for LlamaIndex and context augmentation in general include:

- [Question-Answering](https://docs.llamaindex.ai/en/stable/use_cases/q_and_a/) (Retrieval-Augmented Generation aka RAG)
- [Chatbots](https://docs.llamaindex.ai/en/stable/use_cases/chatbots/)
- [Document Understanding and Data Extraction](https://docs.llamaindex.ai/en/stable/use_cases/extraction/)
- [Autonomous Agents](https://docs.llamaindex.ai/en/stable/use_cases/agents/) that can perform research and take actions
- [Multi-modal applications](https://docs.llamaindex.ai/en/stable/use_cases/multimodal/) that combine text, images, and other data types
- [Fine-tuning models](https://docs.llamaindex.ai/en/stable/use_cases/fine_tuning/) on data to improve performance

## Programming languages

LlamaIndex is available in Python (these docs) and Typescript.

## Start Notebook from WSL command line

To start the environment. Go to your project directory, then:

```bash
conda env create -f environment.yml
conda activate llamaindex-helloworld
jupyter notebook
```

Open the `hello-openai.inpynb` notebook.

When you are done:

```bash
conda deactivate
```

## Reference

- [LlamaIndex documentation](https://docs.llamaindex.ai/en/stable/)
- [LlamaIndex](https://github.com/run-llama/llama_index) on GitHub
