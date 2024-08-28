# Set up tokens and use as environment variables

When you are working on your local development computer and if the secret doesn't change between executions, you can set the secrets in a special file.

## Create the .musictoken file

You can name it anything you want. But for the case of this exercise, create the file using:

```bash
cd ~
cat > ~/.musictoken <<EOF
#!/bin/bash  
#filename: .musictoken
export MUSICSECRET=polkalover  
EOF
```

To test, run:

```bash
# see the file
cat ~/.musictoken
```

To append an environment variable:

```bash
echo "export MUSICPREFEENCE=rockandroll"  >> ~/.musictoken
```

## Make the token file available only to you

Secure the token file so that only the user can see it.

```bash
chmod 600 ~/.musictoken
```

`chmod 600` is a file permission setting in Linux that grants read and write permissions to the owner, while denying all permissions to the group and other users.

## Use the token in a command line

You can load the file and set the token to an environment variable.

```
. ~/.musictoken
```

To see the environment variables:

```bash
# check the tokens
echo $MUSICSECRET $MUSICPREFEENCE
```

> [!NOTE]
> If you want to encrypt your variables as passwords, use [encpass.sh](https://github.com/plyint/encpass.sh/blob/master/README.md)


## References

- [Hiding secret from command line parameter on Unix](https://stackoverflow.com/questions/3830823/hiding-secret-from-command-line-parameter-on-unix)
- [Exploring the new Podman secret command](https://www.redhat.com/sysadmin/new-podman-secrets-command)