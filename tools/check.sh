#!/bin/sh
# SPDX-License-Identifier: BSD-2-Clause
set -eu
if [ "$#" -ne 1 ]; then
    echo 'Usage: tools/check.sh /path/to/opnsense/core' >&2
    exit 1
fi
root=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
core=$(CDPATH='' cd -- "$1" && pwd)
phpcs=${PHPCS_BIN:-phpcs}
[ -f "$core/ruleset.xml" ] || { echo 'OPNsense core ruleset not found.' >&2; exit 1; }
cd "$root"
"$phpcs" --standard="$core/ruleset.xml" opnsense/security/newt/src tests/model.php
find opnsense/security/newt/src -name '*.php' -type f | while IFS= read -r file; do
    php -l "$file" >/dev/null
done
find opnsense/security/newt/src -name '*.xml' -type f -exec xmllint --noout {} +
shellcheck build.sh tools/check.sh \
    opnsense/security/newt/src/opnsense/scripts/OPNsense/Newt/service.sh \
    freebsd/net/pangolin-newt/files/newt.in
python3 tests/templates.py
if php -m | grep -qi '^phalcon$'; then
    php tests/model.php
else
    echo 'OPNsense model runtime check requires Phalcon; run tests/model.php on OPNsense.'
fi
echo 'Source checks passed.'
