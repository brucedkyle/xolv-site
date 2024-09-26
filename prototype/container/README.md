# Set up Python to run in Podman

These files are a prototype to help you get started developing in Python using Podman.

## Prerequisites

You will need:

- WSL
- [Podman](https://podman.io/)
- Visual Studio Code 
- Visual Studio Code extensions
    - [VS Code Remote Development](https://code.visualstudio.com/docs/remote/remote-overview)
    0 
    - [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) - this extension enables to open a folder and execute a code inside a Docker container
    - [Python](https://marketplace.visualstudio.com/items?itemName=ms-python.python) - the main Python plug-in for VScode, enables to execute, debugging, code navigation, code formatting, etc
- [jq](https://jqlang.github.io/jq/download/). To install `sudo apt update; sudo apt install -y jq` The **jq*** is a command line based JSON processor that allows to transform, filter, slice, map, or perform other operations on JSON data.

### Test installation

To test Podman:

```bash
podman version
```

To try out your installation:

```bash
podman run -it --rm python
```
Podman pulls the image and provides you a prompt in Python. Type:

```python
exit()
```

### Build and run Containerfile

Podman uses `Containerfile` or `Dockerfile` as the default name for containers.

```bash
podman build . -f ./ex-1/Containerfile
```
Use `inspect` command to see the image metadata.

```bash
docker inspect python
```

Use the `inspect` command to check if the CMD command was defined.

```bash
podman inspect python | jq '.[] | .Config.Cmd'
```

Run Python.

```bash
podman run --interactive --tty python
```

Try `print("Hello World!")` to run a simple Python line of code.

```text
Python 3.12.6 (main, Sep 12 2024, 21:12:04) [GCC 12.2.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> print("Hello World!")
Hello World!
>>> exit()
```

## Set up the Dev Containers Extension

The `devcontainer.json` defines and customizes the container and VScode setting, such as:

- Image settings - defines the image build method or if to pull an existing one
- Project settings such as extensions to install and command to execute during the launch time of the container

The file goes inside of a `.devcontainer` folder.

Inside `devcontainer.json`, the `build` section defines the image build process. The `dockerfile` argument points out to the `Containerfile` to use for the build. The context argument defines the files' system path for the Dockerfile. Although, we currently do not use the `context` argument in the build time, we will see its applications later. In addition, the `customizations` section enables you to customize the VScode options, such as extensions to install, default Python interpreter, and files to execute during the container launch.

For Podman, ensure that `vscode` is mapped in the container by adding this config to devcontainers.json:

```json
"runArgs": [
  "--userns=keep-id:uid=1000,gid=1000"
 ],
 "containerUser": "vscode",
 "updateRemoteUserUID": true
```

For troubleshooting and more details, see 

To start the project 

## References

- [Setting Python Development Environment with VScode and Docker](https://github.com/RamiKrispin/vscode-python)
- [From Docker to Podman - VS Code DevContainers](https://blog.okikio.dev/from-docker-to-podman-vs-code-devcontainers)
- [Remote container development with VS Code and Podman](https://developers.redhat.com/articles/2023/02/14/remote-container-development-vs-code-and-podman#)
- [Making Visual Studio Code devcontainer work properly on rootless Podman](https://medium.com/@guillem.riera/making-visual-studio-code-devcontainer-work-properly-on-rootless-podman-8d9ddc368b30)