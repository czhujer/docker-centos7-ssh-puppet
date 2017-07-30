# Change Log

## centos-7

Summary of release changes for Version 2 - CentOS-7

### 2.2.3 - 2017-06-14

- Adds clearer, improved [shpec](https://github.com/rylnd/shpec) test case output.
- Updates [supervisor](http://supervisord.org/changes.html) to version 3.3.2.
- Adds use of `/var/lock/subsys/` (subsystem lock directory) for bootstrap lock files.
- Adds a Docker healthcheck.

### 2.2.2 - 2017-05-24

- Updates `openssh` package 6.6.1p1-35.el7_3.
- Replaces deprecated Dockerfile `MAINTAINER` with a `LABEL`.
- Adds a `src` directory for the image root files.
- Adds wrapper functions to functional test cases.
- Adds `STARTUP_TIME` variable for the `logs-delayed` Makefile target.

### 2.2.1 - 2017-02-21

- Updates `vim` and `openssh` packages and the `epel-release`.
- Fixes `shpec` test definition to allow `make test` to be interruptible.
- Adds the `openssl` package (and it's dependency, `make`).
- Adds `README.md` instruction to use `docker pull` before `docker inspect` on an image.

### 2.2.0 - 2016-12-19

- Adds CentOS 7.3.1611 source tag.

### 2.1.5 - 2016-12-15

- Adds updated `sudo`, `openssh`, `yum-plugin-versionlock` and `xz` packages.
- Adds functional tests using [shpec](https://github.com/rylnd/shpec). To run all tests, [install `shpec`](https://github.com/rylnd/shpec#installation) and run with `make test`.
- Adds support for running tests on Ubuntu. _Note: May require some additional setup prevent warnings about locale._

  ```
  sudo locale-gen en_US.UTF-8; sudo dpkg-reconfigure locales
  export LANG=en_US.UTF-8; unset LANGUAGE LC_ALL LC_CTYPE
  ```
- Adds correction to examples and test usage of the `sftp` command.
- Adds a "better practices" example of password hash generation in the `README.md`.
- Adds minor code style changes to the `Makefile`.

### 2.1.4 - 2016-12-04

- Adds correct Makefile usage instructions for 'build' target.
- Adds info regarding NULL port values in Makefile help.
- Removes requirement for `gawk` in the port handling functions for SCMI and the systemd template unit-file.
- Adds reduced number of build steps to image which helps reduce final image size.
- Adds `-u` parameter to `sshd` options to help reduce time spent doing DNS lookups during authentication.
- Adds a change log (`CHANGELOG.md`).
- Adds support for semantic version numbered tags.

### 2.1.3 - 2016-10-02

- Adds Makefile help target with usage instructions.
- Splits up the Makefile targets into internal and public types.
- Adds correct `scmi` path in usage instructions.
- Changes `PACKAGE_PATH` to `DIST_PATH` in line with the Makefile environment include. Not currently used by `scmi` but changing for consistency.
- Changes `DOCKER_CONTAINER_PARAMETERS_APPEND` to `DOCKER_CONTAINER_OPTS` for usability. This is a potentially breaking change that could affect systemd service configurations if using the Environment variable in a drop-in customisation. However, if using the systemd template unit-files it should be pinned to a specific version tag. The Makefile should only be used for development/testing and usage in `scmi` is internal only as the `--setopt` parameter is used to build up the optional container parameters. 
- Removes X-Fleet section from template unit-file.
- Adds support for Base64 encoded `SSH_AUTHORIZED_KEYS` values. This resolves issues with setting multiple keys for the systemd installations.

### 2.1.2 - 2016-09-16

- Fixed issue with sshd process not running on container startup.

### 2.1.1 - 2016-09-15

- Fixes issue running `make dist` before creating package path.
- Removes `Default requiretty` from sudoers configuration. This allows for sudo commands to be run via without the requirement to use the `-t` option of the `ssh` command.
- Adds correct path to scmi on image for install/uninstall.
- Improves readability of Dockerfile.
- Adds consistent method of handling publishing of exposed ports. It's now possible to prevent publishing of the default exposed port when using scmi/make for installation.
- Adds minor improvement to the systemd register template unit-file.
- Adds `/usr/sbin/sshd-wrapper` and moves lock file handling out of supervisord configuration.
- Adds bootstrap script syntax changes for consistency and readability.
- Adds correction to scmi usage instructions; using centos-7-2.1.0 release tag would have resulted in error if attempting an `atomic install`.
- Changes Makefile environment variable from `PACKAGE_PATH` to `DIST_PATH` as the name conflicts with the Dockerfile ARG value used in some downstream builds. This is only used when building the, distributable, image package that gets attached to each release.

### 2.1.0 - 2016-08-26

- Added `scmi` (Services Container Manager Interface) to the image to simplify deployment and management of container instances using simply docker itself, using systemd for single docker hosts or fleet for clustered docker hosts.
- Added metadata labels to the Dockerfile which defines the docker commands to run for operation (install/uninstall). This combined with `scmi` enables the use of Atomic Host's `atomic install|uninistall` commands.
- The `xz` archive package has ben added to the image to allow `scmi` to load an image package from disk instead of requiring registry access to pull release images.
- Updated Supervisor to `3.3.1`.
- Warn operator if any supplied environment variable values failed validation and have been set to a safe default.
- Added `DOCKER_CONTAINER_PARAMETERS_APPEND` which allows the docker operator to append parameters to the default docker create template.
- Removed handling of Configuration Data Volumes from the helper scripts and from the Systemd unit-file definitions. Volumes can be added using the environment variable `DOCKER_CONTAINER_PARAMETERS_APPEND` or with the `--setopt` option with `scmi`.
- Removed the `build.sh` and `run.sh` helper scripts that were deprecated and have been replaced with the Makefile targets. With `make` installed the process of building and running a container from the Dockerfile is `make build install start` or to replicate the previous build helper `make build images install start ps`.
- Systemd template unit-files have been renamed to `centos-ssh@.service` and `centos-ssh.register@.service`. The (optional) register sidekick now contains placeholder `{{SERVICE_UNIT_NAME}}` that is needs gets replaced with the service unit when installing using `scmi`.
- The default value for `DOCKER_IMAGE_PACKAGE_PATH` in the systemd template unit-file has been changed from `/var/services-packages` to `/var/opt/scmi/packages`.

### 2.0.3 - 2016-06-21

- Fixed broken pipe error returned from get_password function in the sshd_bootstrap script.
- Replaced hard-coded volume configuration volume name with Systemd template with the Environment variable `VOLUME_CONFIG_NAME`.
- Fixed issue with setting an empty string for the `DOCKER_PORT_MAP_TCP_22` value - allowing docker to auto-assign a port number.
- Split out build specific configuration from the Makefile into a default.mk file and renamed make.conf to environment.mk - Makefile should now be more portable between Docker projects.

### 2.0.2 - 2016-05-21

- Updated container packages `sudo` and `openssh`.
- Updated container's supervisord to 3.2.3.
- Added `SSH_AUTOSTART_SSHD` && `SSH_AUTOSTART_SSHD_BOOTSTRAP` to allow the operator or downstream developer to prevent the sshd service and/or sshd-bootstrap from startup.
- Added Makefile to replace `build.sh` and `run.sh` helper scripts. See [#162](https://github.com/jdeathe/centos-ssh/pull/162) for notes on usage instructions.
- Set Dockerfile environment variable values in a single build step which helps reduce build time.
- Fixed issue with setting SSH USER UID:GID values in systemd installation.
- Fixed issue with setting of `SSH_SUDO` in Systemd installation.
- Replaced custom awk type filters with docker native commands where possible.
- Fixed issue preventing sshd restarts being possible due to bootstrap lock file dependancy.
- Use `exec` to run the sshd daemon within the container.
- Use `exec` to run the docker daemon process from the systemd unit file template.
- Reduced startup time by ~1 second by not requiring supervisord to wait for the sshd service to stay up for the default 1 second.
- Revised systemd installation process, installer script and service template. `ssh.pool-1.1.1@2020.service` has been replaced by `ssh.pool-1@.service` and local instances are created of the form `ssh.pool-1@1.1`, `ssh.pool-1@2.1`, `ssh.pool-1@3.1` etc. which correspond to docker containers named `ssh.pool-1.1.1`, `ssh.pool-1.2.1`, `ssh.pool-1.3.1` etc. To start 3 systemd managed containers you can simply run:

  ```
  $ for i in {1..3}; do sudo env SERVICE_UNIT_LOCAL_ID=$i ./systemd-install.sh; done
  ```

- The systemd service registration feature is now enabled via an optional service unit template file `ssh.pool-1.register@.service`. 

### 2.0.1 - 2016-03-20

- Fixed '/dev/stdin: Stale file handle' issue seen when using Ubuntu 14.04.4 LTS or Kitematic 0.10.0 as the docker host.
- Fixed default value for `SSH_USER_FORCE_SFTP`.
- Removed the delay for output to docker logs.
- Improved bootstrap startup time and included bootstrap time in the SSHD Details log.
- Added a more robust method of triggering the SSHD process; the sshd-boostrap needs to complete with a non-zero exit code to trigger the SSHD process instead of simply waiting for 2 seconds and starting regardless.
- Systemd definition to use specific tag.

### 2.0.0 - 2016-02-28

- Initial release