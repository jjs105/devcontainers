
# WSLg Support (jjs105-wslg-support)

Configures WSLg and installs associated tools.

## Example Usage

```json
"features": {
    "ghcr.io/jjs105/features/jjs105-wslg-support:3": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| install-pulse-audio | Install the Pulse Audio tools. | boolean | true |
| install-mesa-utils | Install the Mesa utilities (e.g. glxinfo, glxgears). | boolean | true |
| install-x11-apps | Install the X11 app (e.g. xeyes, xclock, etc.). | boolean | true |

<!-- markdownlint-disable-file MD041 -->

## Implementation

Development container feature to add WSLg support to the container.

_Please note that accelerated video support - although described below - does
not currently work._

As detailed below development container features cannot configure runtime
arguments to be passed to docker. This development container feature therefore
adds a simple check for the required device paths via `.bashrc` startup script.

## Additional Configuration

Whilst development container features can add mounts and environment variables
to a development container they cannot specify runtime arguments (runArgs) to
docker.

For this reason this development container feature requires the user to
partially configure the WSLg support in their project's `devcontainer.json` file
by adding the following:

```json
"runArgs": [
  "--device=/dev/dxg",
  "--device=/dev/dri/card0",
  "--device=/dev/dri/renderD128",
  "--gpus=all"
],
```

## Development Notes

The approach used by this development container feature to enable the use of the
Windows WSL2 GUI is based on the sample containers documentation in the official
[MicroSoft wslg repository](https://github.com/microsoft/wslg/).

- https://github.com/microsoft/wslg/blob/main/samples/container/Containers.md

## VSCode Automatic Configuration

Although based on the documentation described above, when using this development
container feature with VSCode as a development environment a number of the
required steps seem to be automagically configured out-of-the-box.

This automatic configuration of WSLg could still be a peculiarity of my
development environment - VSCode (Dev Containers + WSL extensions) on Win 11
with Docker Desktop configured to use WSL.

However, as a test, running a development container based on a bare Alpine image
in VS Code resulted in correctly configured (basic) WSLg support, even when the
VS Code WSL extension was disabled.

Running the same base Alpine image directly from WSL using Docker resulted in no
such automatic WSLg configuration.

## A Note on the DISPLAY Environment Variable

When considering the older X11 implementation of Linux GUI operations, for
correct operation of WSLg the `DISPLAY` environment variable needs to be set
correctly (usually as either `:0` or `:1`).

Dependent on your environment this may be incorrectly set/overridden by VS code.

## Video Acceleration Problems

At the time of writing support for Video Acceleration is not functioning,
however this is because this was also broken on the underlying host system.

The implementation of video acceleration has recently changed and there are
known issues and workarounds associated with both thr Ubuntu OS and NVIDIA
graphics cards/drivers.

In the context of this development container feature, if video acceleration
works on the host WSL system then it should work in the created container.

## Configuration Elements

The table below shows the mounts, environment variables and devices required for
full WSLg support.

|Element|Type|Name/Value|Note|
|-------|----|-----|----|
|X11|Mount|`/tmp/.X11-unix`||
||ENV Variable|`DISPLAY=${DISPLAY}`|Created by VS Code|
|Wayland|Mount|`/mnt/wslg`||
||ENV Variable|`WAYLAND_DISPLAY=${WAYLAND_DISPLAY}`|Created by VS Code|
||ENV Variable|`XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR}`|Created by VS Code|
|PulseAudio|Mount|`/mnt/wslg`|Same as for Wayland|
||ENV Variable|`PULSE_SERVER=${PULSE_SERVER}`||
|vGPU Access|Device*|`/dev/dxg`||
||Mount|`/usr/lib/wsl`||
||ENV Variable|`LD_LIBRARY_PATH =/usr/lib/wsl/lib`||
||Runtime Argument*|`--gpus=all`||
|Acc. Video|Device*|`/dev/dxg`||
||Device*|`/dev/dri/card0`|Same as for vGPU Access|
||Device*|`/dev/dri/renderD128`||
||Mount|`/usr/lib/wsl`|Same as for vGPU Access|
||ENV Variable|`LD_LIBRARY_PATH=/usr/lib/wsl/lib`|Same as for vGPU Access|
||ENV Variable|`LIBVA_DRIVER_NAME=d3d12`|Legacy driver variable|
||ENV Variable|`GALLIUM_DRIVER=d3d12`||

\* Indicates the element must be configured in the project's `devcontainer.json`
file as detailed above.

## Testing

The following commands can be used to test whether your WSLg integration is
working correctly:

```shell
glxinfo -B | grep Device
vainfo
pacat --volume=10000 < /dev/urandom
```



---

_Note: This file was auto-generated from the [devcontainer-feature.json](devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
