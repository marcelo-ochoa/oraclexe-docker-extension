# Docker Extension

Oracle XE extension for Docker Desktop

## Manual Installation

Until this extension is ready at Docker Extension Hub you can install just by executing:

```bash
$ docker extension install mochoa/oraclexe-docker-extension:21.3.0
docker extension install mochoa/oraclexe-docker-extension:21.3.0
Extensions can install binaries, invoke commands and access files on your machine. 
Are you sure you want to continue? [y/N] y
Installing new extension "mochoa/oraclexe-docker-extension:21.3.0"
Installing service in Desktop VM...
Setting additional compose attributes
VM service started
Installing Desktop extension UI for tab "OracleXE"...
Extension UI tab "OracleXE" added.
Extension "OracleXE" installed successfully
```

**Note**: Docker Extension CLI is required to execute above command, follow the instructions at [Extension SDK (Beta) -> Prerequisites](https://docs.docker.com/desktop/extensions-sdk/#prerequisites) page for instructions on how to add it.

**Note**: OracleXE Docker image is big, if you want a fast Docker Extension installation first execute:

```bash
docker pull gvenzl/oracle-xe:21.3.0-full
```

## Using OracleXE Docker Extension

Once the extension is installed a new extension is listed at the pane Extension (Beta) of Docker Desktop.

By clicking at OracleXE icon the extension main window will show this extension in action

![Screenshot of the extension inside Docker Desktop](docs/images/screenshot0.png?raw=true)

A progress indicator bar will wait until OracleXE is ready, first startup will take several seconds depending on your hardware. First click will ask you for the sys user password for OracleXE, 

![Login Screenshot](docs/images/screenshot1.png?raw=true)

fill it with sys/Oracle_2022 (default values on this extension), once you login EM Express is shown:

![Screenshot EMExpress in acton](docs/images/screenshot2.png?raw=true)

### Notes about Oracle Docker XE image

This extension will download three Docker images from DockerHub:

- The extension itself (7.13MB)
- Caddy reverse proxy (44.4MB)
- [Gerald Venzl Oracle XE 21.3.0-full](https://hub.docker.com/r/gvenzl/oracle-xe) optimized image (7GB)

As you can see first execution will wait until Oracle XE image is ready at your machine, please wait and see if you have enough space available ;)

## Sources

As usual the code of this extension is at [GitHub](https://github.com/marcelo-ochoa/oraclexe-docker-extension), feel free to suggest changes and make contributions, note that I am a beginner developer of React and TypeScript so contributions to make this UI better are welcome.
