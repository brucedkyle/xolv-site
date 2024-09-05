# Creating Custom ChatGPT with Your Own Dataset 

This example demonstrates how to build a Chatbot application for the user to interact with ChatGPT. You will traing GPT models with proprietary datasets and develop an applications atop them.

The following technologies are used in this application:

- **OpenAI GPT** is a web-based chatbot application that has been specifically designed and fine-tuned for optimal dialogue interactions.
- **LlamaIndex** (previously known as `gpt-index`) is a data framework which provides a simple, flexible interface to connect LLMs with your private data). You connect data from files like PDFs, PowerPoints, apps such as Notion and Slack and databases like Postgres and MongoDB to LLMs. 
- **LangChain** is a robust library designed to streamline interaction with large language models (LLMs) providers like OpenAI. It supports other LLM providers as such as Cohere, Bloom, Huggingface as well. LangChain’s unique proposition is its ability to create *Chains*, which are logical links between one or more LLMs.

## Prerequisites

You will need:

- [OpenAI API key](http://platform.openai.com/account/api-keys) with [enough credits](http://platform.openai.com/account/usage)

## Set up OpenAI key

Once you get your OpenAI API key, put it into a `.env` file as shown in this steps in this section.

### Create a project folder

Navigate to the location you want to create the project.

```bash
mkdir chat-with-data
cd chat-with-data
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
OPENAI_API_KEY=1168310b-577e-451c-aca0-4e3470f86488

EOF
```

Replace the guid with your actual key. 

> [!IMPORTANT]
> Your `.gitignore` file should include `.env` in its list of files not to check in.

Next, you create the LlamaIndex with your documents.

## Create LlamaIndex

In this step

## Start Notebook from WSL command line

To start the environment. Go to your project directory, then:

```bash
conda env create -f environment.yml
conda activate openai-helloworld
jupyter notebook
```

Open the `hello-openai.inpynb` notebook.

When you are done:

```bash
conda deactivate
```

## Next steps

See:

- [Introduction to prompt engineering](https://learn.microsoft.com/en-us/azure/ai-services/openai/concepts/prompt-engineering) 
- [Prompt engineering techniques](https://learn.microsoft.com/en-us/azure/ai-services/openai/concepts/advanced-prompt-engineering) 
- [OpenAI Cookbook](https://github.com/openai/openai-cookbook)

## References

This article is based on [Creating Custom ChatGPT with Your Own Dataset using OpenAI GPT-3.5 Model, LlamaIndex, and LangChain](https://medium.com/rahasak/creating-custom-chatgpt-with-your-own-dataset-using-openai-gpt-3-5-model-llamaindex-and-langchain-5d5837bf9d56).

- [Developer quickstart](https://platform.openai.com/docs/quickstart?language-preference=python&quickstart-example=completions&desktop-os=windows) OpenAI documentation