#!/bin/bash -e

python3 -m pip --no-cache-dir install --upgrade conan >/dev/null 2>&1 || true

exec "$@"
