# Set up tokens and use as environment variables

When you are working on your local development computer and if the secret doesn't change between executions, you can set the secrets in a special file.

Secrets can be about databases, passwords, API gateways, operating modes that determine whether our app is running in developer or production mode. Basically, all the code you need to actually access the different functions of your app.

Those tokens, secrets, passwords might not necessarily be things which you want your user to be able to see.

In this tutorial you will see how to use a `.env` file to make it easier to share with teammates while allowing them to set their own environmental variables, but not necessarily check in and let the whole world see.

> [!IMPORTANT]
> This demonstrates how to store the tokens in the clear. 

## Set .gitignore

When you build out a project in Git, you will have a file named `.gitignore`. Open it to be sure that the list of files Git ignores on check in include. You should see, 

```text
.env
```

## Create the .env file

To configure the development environment, add a .env in the root directory of your project:

```text
.
├── .env
└── foo.py

```

For example, use:

```bash
cd ~
cat > ~/project/.env <<EOF
#!/bin/bash  
#filename: .env
MUSICSECRET=polkalover  
EOF
```

To test, run:

```bash
# see the file
cat ~/project/.env
```

To append an new environment variable:

```bash
echo "MUSICPREFEENCE=rockandroll"  >> ~/project/.env
```

## Make the token file available only to you

Secure the token file so that only the user can see it.

```bash
chmod 600 ~/project/.env
```

`chmod 600` is a file permission setting in Linux that grants read and write permissions to the owner, while denying all permissions to the group and other users.

## Use the token in a command line

You can load the file and set the token to an environment variable.

```
. ~/project/.musictoken
```

To see the environment variables:

```bash
# check the tokens
echo $MUSICSECRET $MUSICPREFEENCE
```

> [!NOTE]
> If you want to encrypt your variables as passwords, use [encpass.sh](https://github.com/plyint/encpass.sh/blob/master/README.md)

## Use the keys in your Jupyter Notebook

To use the keys in a notebook in three steps:

1. Install `dotenv` into your Python environment.
2. Load the environment in your .env file and assign variables in your application

Let's start with installing dotevn

### Install `dotenv` in your Python environment

You can install using pip or conda.

```bash
conda install conda-forge::python-dotenv
## or
## pip install python-dotenv
```

### Load the environment in your .env file and assign variables in your application

At the top of your notebook:

```python
from dotenv, import load_dotenv

def configure() -> None:
    """Load environment variables and configure OpenAI API key."""
    load_dotenv()
    music_secret = os.getenv("MUSICSECRET")
    music_preference = os.getenv("MUSICPREFEENCE")
    openai.api_key = os.getenv("OPENAI_API_KEY")
```

With `load_dotenv(override=True)` or `dotenv_values()`, the value of a variable is the first of the values defined in the following list:

1. Value of that variable in the `.env` file.
2. Value of that variable in the environment.
3. Default value, if provided.
4/ Empty string.

With `load_dotenv(override=False)`, the value of a variable is the first of the values defined in the following list:

1. Value of that variable in the environment.
2. Value of that variable in the .env file.
3. Default value, if provided.
4. Empty string.

To test:

```python
configure()
print("MUSICSECRET = ", music_secret)
print("MUSICPREFEENCE = ", music_preference)
print("OPENAI_API_KEY = ", openai.api_key)
```

### Another technique

You can also use magic commands to load your `.env` data.

```python
%load_ext dotenv
%dotenv
```

## For more information and techniques

See [python-dotenv](https://saurabh-kumar.com/python-dotenv/)

## References

- [Hiding secret from command line parameter on Unix](https://stackoverflow.com/questions/3830823/hiding-secret-from-command-line-parameter-on-unix)
- [Exploring the new Podman secret command](https://www.redhat.com/sysadmin/new-podman-secrets-command)
- [Using .env files: what they are, and when to use them](https://medium.com/@michaeldipasquale313/using-env-files-what-they-are-and-when-to-use-them-4f4812c5732f)