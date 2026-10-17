#!/bin/sh
# SPDX-License-Identifier: BSD-2-Clause
# Build the package on the target FreeBSD/OPNsense release.
set -eu
umask 022
[ "$(uname -s)" = FreeBSD ] || { echo 'Build on FreeBSD/OPNsense.' >&2; exit 1; }
source_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
build=$(mktemp -d /tmp/os-newt-build.XXXXXX)
trap 'rm -rf "$build"' EXIT
trap 'exit 1' HUP INT TERM
stage="$build/stage"
metadata="$build/metadata"
mkdir -p "$stage/usr/local" "$metadata" "$source_dir/dist"
cp -R "$source_dir/src/" "$stage/usr/local/"
case "$(uname -m)" in
    amd64) arch=amd64; digest=d2e12ca03ba060ab8c97ee827359d54c1fb6428ea5bf7f1bc9b500236d6cebc2 ;;
    arm64|aarch64) arch=arm64; digest=5c02e3fb3726a1c251f63edee21cadf62b1cc9fa2aee111b4c80d9358ff8be05 ;;
    *) echo 'Unsupported architecture.' >&2; exit 1 ;;
esac
mkdir -p "$stage/usr/local/sbin" "$stage/usr/local/share/doc/os-newt" "$stage/usr/local/opnsense/version"
fetch -o "$stage/usr/local/sbin/newt" "https://github.com/fosrl/newt/releases/download/1.18.1/newt_freebsd_${arch}"
[ "$(sha256 -q "$stage/usr/local/sbin/newt")" = "$digest" ] || { echo 'Newt checksum mismatch.' >&2; exit 1; }
fetch -o "$stage/usr/local/share/doc/os-newt/LICENSE.newt" 'https://raw.githubusercontent.com/fosrl/newt/1.18.1/LICENSE'
cp "$source_dir/LICENSE" "$source_dir/README.md" "$stage/usr/local/share/doc/os-newt/"
find "$stage" -type d -exec chmod 755 {} +
find "$stage" -type f -exec chmod 644 {} +
chmod 755 "$stage/usr/local/sbin/newt" "$stage/usr/local/etc/rc.d/newt"
chmod 755 "$stage/usr/local/opnsense/scripts/OPNsense/Newt/"*

export NEWT_BUILD_STAGE="$stage" NEWT_BUILD_METADATA="$metadata" NEWT_BUILD_ARCH="$arch"
php <<'PHP'
<?php
$annotations = [
    'product_id' => 'os-newt', 'product_name' => 'newt',
    'product_version' => '1.0', 'product_tier' => '4',
    'product_abi' => trim(shell_exec('opnsense-version -a')),
    'product_arch' => getenv('NEWT_BUILD_ARCH'),
    'product_website' => 'https://github.com/fosrl/newt',
    'product_email' => 'local@localhost',
];
$manifest = [
    'name' => 'os-newt', 'version' => '1.0', 'origin' => 'local/os-newt',
    'comment' => 'Pangolin Newt connector with WebUI and service controls',
    'desc' => 'Locally maintained OPNsense plugin. Bundles official Newt 1.18.1.',
    'maintainer' => 'local@localhost', 'www' => 'https://github.com/fosrl/newt',
    'prefix' => '/usr/local', 'categories' => ['net', 'security'],
    'licenselogic' => 'multi', 'licenses' => ['BSD2CLAUSE', 'AGPLv3'],
    'abi' => trim(shell_exec('pkg config ABI')),
    'annotations' => $annotations,
    'scripts' => [
        'post-install' => '/usr/local/opnsense/scripts/OPNsense/Newt/setup.sh',
        'pre-deinstall' => '/usr/local/opnsense/scripts/OPNsense/Newt/service.sh stop || true',
        'post-deinstall' => "rm -f /etc/rc.conf.d/newt /usr/local/etc/newt/config.json\n"
            . "service configd restart\n/usr/local/etc/rc.configure_plugins POST_DEINSTALL\n",
    ],
];
file_put_contents(getenv('NEWT_BUILD_METADATA') . '/+MANIFEST', json_encode($manifest, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES));
file_put_contents(getenv('NEWT_BUILD_STAGE') . '/usr/local/opnsense/version/newt', json_encode($annotations, JSON_PRETTY_PRINT));
PHP
find "$stage/usr/local" -type f | sed "s|^$stage/usr/local/||" | sort > "$build/plist"
pkg create -r "$stage" -m "$metadata" -p "$build/plist" -o "$source_dir/dist"
echo "Package written to $source_dir/dist"
