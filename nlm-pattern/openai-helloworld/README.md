# OpenAI hello world

This example demonstrates how to install and run two simple **OpenAI** prompts in a Jupyter Notebook. It is based on the example in the OpenAI [Developer quickstart](https://platform.openai.com/docs/quickstart?language-preference=python&quickstart-example=completions&desktop-os=windows).

## Create a project folder

Navigate to the location you want to create the project.

```bash
mkdir openai-helloworld
cd openai-helloworld
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

- [Developer quickstart](https://platform.openai.com/docs/quickstart?language-preference=python&quickstart-example=completions&desktop-os=windows) OpenAI documentation