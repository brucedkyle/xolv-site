# Set up your secrets for Docker

You can provide sensitive data to your Docker container, such as passwords, API keys, and certificates.

There are several ways to pass in the secret.

- Use Docker Secrets and Docker Swarm. If you want to do this, see [Gettins started with swarm mode](https://learn.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/swarm-mode) and then [How to Handle Secrets in Docker](https://blog.gitguardian.com/how-to-handle-secrets-in-docker/). You'll need Windows Server to do this.
- Use Docker Compose. Docker Compose provides an effective solution for managing secrets for organizations handling sensitive data such as passwords or API keys. You can read your secrets from an external file (like a TXT file).

## Set up Docker and Docker Compose

1. See [Docker and Docker Compose on Windows Subsystem for Linux (WSL)](https://medium.com/@dufrtss/docker-and-docker-compose-on-windows-subsystem-for-linux-wsl-bd4517d2557b)

## References

- [Docker Secrets: An Introductory Guide with Examples](https://medium.com/@laura_67852/docker-secrets-an-introductory-guide-with-examples-d25be5fc8e50)