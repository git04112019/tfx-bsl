#!/bin/bash
# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Convenience binary to build TFDV from source.

# Put wrapped c++ files in place

# Usage: build_pip_package.sh [--python_bin_path PYTHON_BIN_PATH]

if [[ -z "$1" ]]; then
  PYTHON_BIN_PATH=python
else
  if [[ "$1" == --python_bin_path ]]; then
    shift
    PYTHON_BIN_PATH=$1
  else
    printf "Unrecognized argument $1"
    exit 1
  fi
fi

PLATFORM="$(uname -s | tr 'A-Z' 'a-z')"
function is_windows() {
  if [[ "${PLATFORM}" =~ (cygwin|mingw32|mingw64|msys)_nt* ]]; then
    true
  else
    false
  fi
}

set -u -x

if is_windows; then
  TFX_BSL_EXTENSION="tfx_bsl/cc/tfx_bsl_extension.pyd"
  cp -f "${BUILD_WORKSPACE_DIRECTORY}/bazel-out/x64_windows-opt/bin/${TFX_BSL_EXTENSION}" \
    "${BUILD_WORKSPACE_DIRECTORY}/${TFX_BSL_EXTENSION}"
  cp -f "${BUILD_WORKSPACE_DIRECTORY}"/bazel-genfiles/tfx_bsl/proto/*.py \
    "${BUILD_WORKSPACE_DIRECTORY}"/tfx_bsl/proto
else
  # If run by "bazel run", $(pwd) is the .runfiles dir that contains all the
  # data dependencies.
  RUNFILES_DIR=$(pwd)
  TFX_BSL_EXTENSION="tfx_bsl/cc/tfx_bsl_extension.so"
  cp -f "${RUNFILES_DIR}/${TFX_BSL_EXTENSION}" \
    "${BUILD_WORKSPACE_DIRECTORY}/${TFX_BSL_EXTENSION}"
  cp -f "${RUNFILES_DIR}"/tfx_bsl/proto/*.py \
    "${BUILD_WORKSPACE_DIRECTORY}/tfx_bsl/proto/"
fi
chmod +w "${BUILD_WORKSPACE_DIRECTORY}/${TFX_BSL_EXTENSION}"


# Create the wheel
cd ${BUILD_WORKSPACE_DIRECTORY}

${PYTHON_BIN_PATH} setup.py bdist_wheel

# Cleanup
cd -
