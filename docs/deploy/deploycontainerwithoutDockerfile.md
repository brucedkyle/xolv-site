# Deploy source code to image without a Dockerfile

[Source-to-Image (S2I)](https://github.com/openshift/source-to-image) is a toolkit and workflow for building reproducible container images from source code. S2I produces ready-to-run images by injecting source code into a container image and letting the container prepare that source code for execution. By creating self-assembling builder images, you can version and control your build environments exactly like you use container images to version your runtime environments.

## Source-to-image build process overview

Source-to-image (S2I) produces ready-to-run images by injecting source code into a container that prepares that source code to be run. It performs the following steps:

1. Runs the `FROM <builder image>` command
2. Copies the source code to a defined location in the builder image
3. Runs the assemble script in the builder image
4. Sets the run script in the builder image as the default command

Buildah then creates the container image.

## Prerequisites

- Podman installed

## Installation

Download the [latest release](https://github.com/openshift/source-to-image/releases/latest).

Choose either the linux-386 or the linux-amd64 links for 32 and 64-bit, respectively.

Unpack the downloaded tar with

```bash
tar -xvzf release.tar.gz.
```

You should now see an executable called s2i. Either add the location of s2i to your PATH environment variable, or move it to a pre-existing directory in your PATH. For example,

```bash
cp /path/to/s2i /usr/local/bin
```

will work with most setups.

## To test

To try it out, use the following command.

```bash
s2i build https://github.com/sclorg/django-ex centos/python-35-centos7 hello-python
podman run -p 8080:8080 hello-python
```

Now browse to http://localhost:8080 to see the running application.

## Inside OpenShift

S2I images are available for you to use directly from the OpenShift Container Platform web console by following procedure:

1. Log in to the OpenShift Container Platform web console using your login credentials. The default view for the OpenShift Container Platform web console is the **Administrator** perspective.
2, Use the perspective switcher to switch to the **Developer** perspective.
3. In the **+Add** view, use the **Project** drop-down list to select an existing project or create a new project.
4.Click **All services** in the **Developer Catalog** tile.
5. Click **Builder Images** under **Type** to see the available S2I images.

S2I images are also available though the Cluster Samples Operator.

## For more information

See:

- [Creating images from source code with source-to-image](https://docs.openshift.com/container-platform/4.16/openshift_images/create-images.html#images-create-s2i_create-images)


## Reference

- [Source-to-Image (S2I)](https://github.com/openshift/source-to-image)
- Red Hat documentation [Source-to-image](https://docs.openshift.com/container-platform/4.16/openshift_images/using_images/using-s21-images.html)