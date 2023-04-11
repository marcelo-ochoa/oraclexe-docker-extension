# Oracle Free Docker Extension

Oracle Free extension for Docker Desktop

## Manual Installation

Until this extension is ready at Docker Extension Hub you can install with the [Extension CLI](https://docs.docker.com/desktop/extensions-sdk/#prerequisites):

```bash
$ docker extension install mochoa/oraclexe-docker-extension:oracle-free-23.2.0-faststart
docker extension install mochoa/oraclexe-docker-extension:oracle-free-23.2.0-faststart
Extensions can install binaries, invoke commands and access files on your machine. 
Are you sure you want to continue? [y/N] y
Installing new extension "mochoa/oraclexe-docker-extension:oracle-free-23.2.0-faststart"
Installing service in Desktop VM...
Setting additional compose attributes
VM service started
Installing Desktop extension UI for tab "Oracle Free"...
Extension UI tab "Oracle Free" added.
Extension "OracleFree Developer Edition 23c embedded RDBMS - Faststart" installed successfully
```

**Note**: Docker Extension CLI is required to execute above command, follow the instructions at [Extension SDK (Beta) -> Prerequisites](https://docs.docker.com/desktop/extensions-sdk/#prerequisites) page for instructions on how to add it.

**Note**: Oracle Free Docker image is big (1.33GB), is strongly recommended that first execute:

```bash
docker pull gvenzl/oracle-free:23.2-slim-faststart
```

## Using Oracle Free Docker Extension

Once the extension is installed a new extension is listed at the pane Extension of Docker Desktop.

By clicking at Oracle Free icon the extension main window will show this extension in action

![Screenshot of the extension inside Docker Desktop](docs/images/screenshot1.png?raw=true)

A progress indicator bar will wait until Oracle Free is ready, first startup will take several seconds depending on your hardware. By default scott user is added as part of the startup script, just connect using tiger password as is shown below

![Login Screenshot](docs/images/screenshot2.png?raw=true)

also sys user is available with password **Oracle_2023** (default values on this extension):

![Screenshot SQLcl in acton](docs/images/screenshot3.png?raw=true)

### Notes about Oracle Docker Free image

This extension will download three Docker images from DockerHub:

- The extension itself (270MB)
- [Gerald Venzl Oracle Free 23.2-slim-faststart](https://hub.docker.com/r/gvenzl/oracle-free) image (5.85GB uncompressed size)

As you can see first execution will wait until Oracle Free image is ready at your machine, please wait and see if you have enough space available ;)

## Sources

As usual the code of this extension is at [GitHub](https://github.com/marcelo-ochoa/oraclexe-docker-extension/tree/oracle-free-23.2.0-faststart), feel free to suggest changes and make contributions, note that I am a beginner developer of React and TypeScript so contributions to make this UI better are welcome.
