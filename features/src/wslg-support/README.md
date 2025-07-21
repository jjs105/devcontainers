
# Windows WSL GUI Support (wslg-support)

Adds Windows WSL based GUI, GPU and accelerated video support to a development container.

## Example Usage

```json
"features": {
    "ghcr.io/jjs105/features/wslg-support:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| install-x11-apps | Install the X11 app (e.g. xeyes, xclock, etc.). | boolean | true |
| install-mesa-utils | Install the Mesa utilities (e.g. glxinfo, glxgears). | boolean | true |
| check-device-dxg | On startup check the /dev/dxg device (vGPU support). | boolean | true |
| check-device-video | On startup check the /dev/dri/card0+renderD128 devices (acc. video support). | boolean | true |

_Please note that accelerated video support - although described below - does
not currently work._

As detailed below this development container feature cannot configure runtime
arguments to be passed to docker. The `check-*` options above therefore are used
to configure a script which runs on startup alerting the user to incorrect
configuration.

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
[MicroSoft wslg repoistory](https://github.com/microsoft/wslg/).

- https://github.com/microsoft/wslg/blob/main/samples/container/Containers.md

## VSCode Automatic Configuration

Although based on the documentation descibed above, when using this development
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
||ENV Variable|`LD_LIBRARY_PATH =/usr/lib/wsl/lib`|Same as for vGPU Access|
||ENV Variable|`LIBVA_DRIVER_NAME=d3d12`||

\* Indicates the element must be configured in the project's `devcontainer.json`
file as detailed above.

<!-- markdownlint-disable-file MD041 -->


---

_Note: This file was auto-generated from the [devcontainer-feature.json](devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
