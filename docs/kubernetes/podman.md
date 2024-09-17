# Getting started with Podman

<img style="float: right;" alt="" src="./media/podman-2-196w-172h.png" />

[Podman](https://www.redhat.com/en/topics/containers/what-is-podman) is a container engine that's compatible with the OCI Containers specification. Podman is part of RedHat Linux, but can also be installed on other distributions, including Windows and MacOS.

The biggest argument for using Podman over Docker is am eye toward security. Two of Podman's primary features will attract you. 

- Podman does not run as a daemon, meaning it doesn't rely on a process with root privileges to run containers.
- Podman can run containers without root access. It means that you do not need superuser privileges to mange containers.

## Podman key features

Docker has been the go-to containerization tool for years, but Podman is emerging as a strong alternative. Podman offers a few advantages:

- **Rootless Containers**. Run containers without needing root privileges, enhancing security. [Learn more about rootless containers](https://opensource.com/article/19/2/how-does-rootless-podman-work).
- **Systemd Integration**. Better integration with Linux's init system, systemd. For Linux users, this is a significant benefit. Podman's compatibility with systemd offers better process management and orchestration. [Learn more about systemd](https://www.linux.com/training-tutorials/understanding-and-using-systemd/).
- **Follows Open Standards**. Fully compatible with [Open Container Initiative (OCI)](https://opencontainers.org/) standards. Podman is [OCI-compliant](https://opencontainers.org/), which means it adheres to industry standards for container images, making it easier to switch between different container technologies. [Learn more about OCI](https://opencontainers.org/about/overview/).
- **Deploy to Kubernetes**. Deploy pods from Podman Desktop to local or remote Kubernetes contexts using automatically-generated YAML config.
- **Podman is compatible with Docker's command line interface**. Meaning, moving from Docker to Podman will not require any major changes to your existing code. This also means that you can just substitute the docker command with podman and it just works.
- **Podman is daemon-less**. Docker's core runs as a daemon (dockerd). Meaning, it is always running in the background, managing the containers. Meanwhile, Podman is like your average program; once you perform an action (start/stop a container) using Podman, it exits.

## Prerequisites

Since Podman uses [WSL](https://learn.microsoft.com/en-us/windows/wsl/about), you need a recent release of Windows 10 or Windows 11. On x64, WSL requires build 18362 or later, and 19041 or later is required for arm64 systems. Internally, WSL uses virtualization, so your system must support and have hardware virtualization enabled. If you are running Windows on a VM, you must have a VM that supports nested virtualization.

Recommended:

- [Windows Terminal](https://github.com/microsoft/terminal)

## Install on Windows

 On Windows, each Podman machine is backed by a virtualized Windows Subsystem for Linux (WSLv2) distribution. 

To install Podman for Windows, download and install Podman from the [official site](https://github.com/containers/podman/blob/main/docs/tutorials/podman-for-windows.md).

To check your installation:

```bash
podman version
```

For information on how to use Podman on a remote client, see [Podman Remote clients for macOS and Windows](https://github.com/containers/podman/blob/main/docs/tutorials/mac_win_client.md).

## Initialize and start Podman

Before using Podman, you need to initialize and start a Podman machine:

```bash
podman machine init
podman machine start
```

## Run something

```bash
podman run ubi8-micro date
```

## Podman has Pods

Podman comes with unique features that Docker lacks entirely. In Podman, containers can form "pods" that operate together. It's similar to the Kubernetes Pod concept.

To create a Pod, use the pod create command:

```bash
podman pod create --name my-pod
```

Add containers to Pods, by including the `--pod`` folg with `podman run`.

```
podman run --pod my-pod --name image-1 my-image:latest

podman run --pod my-pod --name image-2 another-image:latest
```

Containers in the Pod can be managed in aggregate by using podman pod commands:

```bash
podman kill my-pod # Kill all containers

podman restart my-pod # Restart all containers

podman stop my-pod # Stop all containers
```

The Pod concept is powerful, as it lets you manage multiple containers in aggregate. You can create app containers, such as a frontend, a backend, and a database, add them to a Pod, and manage them in unison.

The closest Docker gets to this is with [Compose](https://www.howtogeek.com/devops/what-is-docker-compose-and-how-do-you-use-it/). Using `Compose` requires you to write a `docker-compose.yml` file and use the separate docker-compose binary. Podman lets you create Pods using one command without leaving the terminal.

When you need to export a Pod's definition, Podman will produce a Kubernetes-compatible YAML manifest. You can take the manifest and apply it directly to a Kubernetes cluster. This narrows the gap between running a container in development and launching it onto production infrastructure.

```bash
podman generate kube
```

## Rootless containers

Podman supports rootless containers. This helps you lock down your security by preventing containers from running as the host's root user. Docker now supports rootless mode as a daemon configuration option. 

_Rootless containers_ are containers that can be created, run, and managed by users without admin rights. Rootless containers have several advantages:

They add a new security layer; even if the container engine, runtime, or orchestrator is compromised, the attacker won't gain root privileges on the host.
They allow multiple unprivileged users to run containers on the same machine (this is especially advantageous in high-performance computing environments).

They allow for isolation inside of nested containers.
To better understand these advantages, consider traditional resource management and scheduling systems. This type of system should be run by unprivileged users. From a security perspective, fewer privileges are better. With rootless containers, you can run a containerized process as any other process without needing to escalate any user's privileges. There is no daemon; Podman creates a child process.

For more information, see [Rootless Tutorial](https://github.com/containers/podman/blob/main/docs/tutorials/rootless_tutorial.md)

## Podman, Buildah, and Skopeo

Podman is a modular container engine, so it must work alongside tools like [Buildah](https://www.redhat.com/en/topics/containers/what-is-buildah) and [Skopeo](https://www.redhat.com/en/topics/containers/what-is-skopeo) to build and move its containers. 

With Buildah, you can build containers either from scratch or by using an image as a starting point. Skopeo moves container images between different types of storage systems, allowing you to copy images between registries like docker.io, quay.io, and your internal registry or between different types of storage on your local system. 

## Next steps

Get the [Podman Basics Cheat Sheet](https://developers.redhat.com/cheat-sheets/podman-basics-cheat-sheet?intcmp=701f20000012ngPAAQ)

## References

- [From Docker to Podman - VS Code DevContainers](https://blog.okikio.dev/from-docker-to-podman-vs-code-devcontainers)
- [Making Visual Studio Code devcontainer work properly on rootless Podman](https://medium.com/@guillem.riera/making-visual-studio-code-devcontainer-work-properly-on-rootless-podman-8d9ddc368b30)
- [Run Podman on Windows: How-to instructions](https://www.redhat.com/sysadmin/run-podman-windows)
- [What Is Podman and How Does It Differ from Docker?](https://www.howtogeek.com/devops/what-is-podman-and-how-does-it-differ-from-docker/)
- [What is Podman?](https://www.redhat.com/en/topics/containers/what-is-podman)
