#!/usr/bin/env bash

set -e

export HOME=/tmp/home
mkdir -p "${HOME}"

# Initialize the wine prefix (virtual windows installation)
export WINEPREFIX=/tmp/wine
mkdir -p "${WINEPREFIX}"
# FIXME: Make the wine prefix initialization faster
wineboot &> /dev/null

# shellcheck disable=SC1091
. msvc-env.sh

exec "$@"
