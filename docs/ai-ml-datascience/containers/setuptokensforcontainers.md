# Set up your tokens, passwords, secrets for Podman

How do you pass in the password to a database or a token to access an online service? You could simply a file when running the container and store the credentials there?

If the container is exported into the image, the credentials would be exported as well. Anyone who has control over the image would be able to access the database.

Or you can pass the credentials using the CLI. But then you need to enter the data everytime you run the container.

In this article, you learn how to set up your token and pass it into a running container. First, Podman, then Docker.

## Set up your tokens for Podman

You can use `podman secret` alone with their sub-commands `create, rm, ls`, and `inspect`. And you can use the `--secret` flag to inject the secret into the container.

Podman secrets are available in Podman 3.1.0. Podman 4.3.0 added support for Kubernetes secrets on top of Podman secrets using the `podman kube play` command.

### Set up, inspect, remove the secret 

Let's begin by setting up your secret data into a file named `.secretfile`. And to name of the secret is `secretname`

```bash
echo "supersecretdata" > .secretfile
podman secret create secretname .secretfile
```

Next use the `podman secret inspect` command to see the metadata on the secret in Podman.

```bash
podman secret inspect secretname
```

Returns

```json
[
    {
        "ID": "94852d928258719b29d24323e",
        "CreatedAt": "2024-08-17T08:16:36.234868975-07:00",
        "UpdatedAt": "2024-08-17T08:16:36.234868975-07:00",
        "Spec": {
            "Name": "secretname",
            "Driver": {
                "Name": "file",
                "Options": {
                    "path": "/home/bruce/.local/share/containers/storage/secrets/filedriver"
                }
            }
        }
    }
]
```

You can list the secrets:

```bash
podman secret ls
```
And receive

```text
ID                         NAME        DRIVER      CREATED         UPDATED
94852d928258719b29d24323e  secretname  file        44 seconds ago  44 seconds ago
```

and remove them

```bash
podman secret rm secretname
```

### Pass the secret into the container

You pass in the secret name using the `--secret` flag. Then inside the container, the secret is in a file named `/run/secrets/secretname`. You can use the `--secret` flag multiple times to add numerous secrets to the container.

In the following command, you run podman in a container named `acontainer`. The container uses the `alpine` image. And then runs the `cat` command to see the value in the `/run/secrets/secretname` file. The `-it` terminates the container after it runs.

```bash
podman run -it --secret secretname --name acontainer alpine cat /run/secrets/secretname
```

!!! note "Secrets are not committed to an image"

    Secrets will not be committed to an image or exported with a `podman commit` or a `podman export` command. This prevents sensitive information from accidentally being pushed to a public registry or given to the wrong person.

## Podman Cheatsheet

Download [Podman Cheat Sheet](https://developers.redhat.com/cheat-sheets/podman-cheat-sheet)

## References

- [Exploring the new Podman secret command](https://www.redhat.com/sysadmin/new-podman-secrets-command)