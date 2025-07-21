#!/bin/bash

#-------------------------------------------------------------------------------
# Copyright (c) Jon Spain (https://github.com/jjs105).
# Licensed under GNU GPL v3 or later
# https://github.com/jjs105/devcontainers/tree/main/LICENSE
#-------------------------------------------------------------------------------

[ -f "/opt/jjs105/etc/.check-vgpu" ] && \
  [ -e /dev/dxg ] \
    && echo "vGPU support enabled" \
      || echo "vGPU support not enabled"

[ -f "/opt/jjs105/etc/.check-accvid" ] && \
  ([ -e /dev/dri/card0 ] || [ -e /dev/dri/renderD128 ]) \
    && echo "Accelerated video support enabled" \
      || echo "Accelerated video support not enabled"
