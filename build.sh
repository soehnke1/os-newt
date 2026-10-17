#!/bin/sh
# SPDX-License-Identifier: BSD-2-Clause
set -eu
if [ "$#" -ne 1 ]; then
    echo 'Usage: sh build.sh /path/to/opnsense/plugins' >&2
    exit 1
fi
root=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
plugins=$(CDPATH='' cd -- "$1" && pwd)
[ -f "$plugins/Mk/plugins.mk" ] || { echo 'Not an OPNsense plugins checkout.' >&2; exit 1; }
[ ! -e "$plugins/security/newt" ] || { echo 'security/newt already exists; review it before replacing.' >&2; exit 1; }
cp -R "$root/opnsense/security/newt" "$plugins/security/newt"
make -C "$plugins/security/newt" package
