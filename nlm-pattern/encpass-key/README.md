# Set and get your secrets in your dev environment

Sensitive data (passwords etc.) should not be placed directly in the configuration files or in your code. Most of the demos that require tokens show you putting the token in the code itself, which can compromise your token when you save it.

> [!IMPORTANT]
> Sensitive data, such as passwords and API tokens, should not be placed directly in the configuration files that can be checked in.

A common approach is to use environment variables. You can assign sensitive data to the environment variables and use these variables later on in your configuration/scripts/code.

In this article, you learn how you can get and set your token and keep it pretty safe in your dev enviornment.

## For your dev environment

[encpass.sh](https://github.com/plyint/encpass.sh) helps you store a secret in a reasonably safe way and retrieve it easily in a bash script.

Using this method, your secrets are encrypted using symmetric keys and both values (secret + password) are stored in a hidden directory that can only be accessed by the user who run the script. It obviously doesn't protect from situations in which attacker has an access to the user's hidden directory (for example if an attacker has a root access).

## Get encpass and put it on your path

[encpass.sh](https://github.com/plyint/encpass.sh) provides a lightweight solution for using encrypted passwords in shell scripts. It allows a user to encrypt a password (or any other secret) at runtime and then use it, decrypted, within a script. This prevents shoulder surfing secrets and avoids storing the secret in plain text, which could inadvertently be sent to or discovered by an individual at a later date.

To install:

```bash
cd /usr/local/bin
curl https://raw.githubusercontent.com/ahnick/encpass.sh/master/encpass.sh -o /usr/local/bin/encpass.sh
```

## Create a configuration file 

Go to your working directory:

```bash
mkdir ~/project
cd ~/project
```

Create a file, such as `project_token.sh`:

```sh
#!/bin/sh

. encpass.sh
export MY_TOKEN=$(get_secret project_token.sh my_token)

echo "MY_TOKEN=\$(get_secret project_token.sh my_token)"
echo "MY_TOKEN = $MY_TOKEN"
echo ""
```

This files uses the `get_secret` command that is in **encpass** with the parameters `project_tokens.sh` as the bucket name and `my_token` for the name you use to access the token.

> [!NOTE]
> You can have more than one token/secret/password in a your configuration file, but they should have different names.

## Run the configuration file and save your token

Run the configuration file:

```
./project_token.sh
```

The script will ask your token:

```text
Enter my_token:
```

Paste in your token (such as `hf_UluV` ), press enter. It will ask you to confirm. Paste it in again. The configuration file script then calls `get_secret project_tokens.sh my_token` and echos the call and the variable back to you, such as:

```text
MY_TOKEN=$(get_secret project_tokens.sh my_token)
MY_TOKEN = hf_UluV
```

## Use your configuration script

Use your configuration file to set the environment variables.

Your script looks like this:

```sh
. project_token.sh

export MY_TOKEN_2=$(get_secret project_token.sh my_token)
echo $MY_TOKEN_2 # just to see it for yourself
```

## Get the variable in your Jupyter Notebook

To see the variables that were passed into the Notebook use the magic command:

```python
%env 
#is MY_TOKEN and MY_TOKEN_2 there?
```

```python
%env MY_TOKEN
```

You can then access your environment variable in your Jupyter Notebook:

```python
import os
my_token = os.environ['MY_TOKEN']
```

OR

```python
from dotenv import load_dotenv


```

## References

- [Sensitive data in bash scripts](https://dev.to/msedzins/sensitive-data-in-bash-scripts-3j5c)
- GitHub [encpass.sh](https://github.com/plyint/encpass.sh)