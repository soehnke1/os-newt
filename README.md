# Pangolin Newt for OPNsense

Preparation for an OPNsense plugin contribution. The integration provides **VPN → Pangolin Newt** settings, service controls and logs. Resource definitions and access policies remain on the Pangolin server.

| Directory | Destination | Purpose |
| --- | --- | --- |
| `opnsense/security/newt` | `opnsense/plugins`, `security/newt` | BSD-2-Clause MVC/API plugin, `os-newt` |
| `freebsd/net/pangolin-newt` | FreeBSD ports, `net/pangolin-newt` | AGPLv3 daemon built from source, `pangolin-newt` |
| `docs/upstream` | Contribution preparation | Discussion draft, review checklist and submission drafts |

**Not yet accepted by OPNsense or FreeBSD.** No Pangolin Newt port was found in FreeBSD ports or the OPNsense ports tree at preparation time. Dependency acceptance, OPNsense build-tree availability, a maintainer commitment and the preliminary upstream discussion remain prerequisites. This repository remains private.

## Configuration

For manual installation, upgrading from the combined v1.0 package, WebUI/service checks, an iPhone connectivity test and rollback, see the [German installation and test guide](docs/INSTALLATION.de.md).

Settings include activation, HTTPS server address, site ID, masked secret, log level, MTU and optional UDP port/DNS server. Credentials are required when enabling Newt. Save/apply uses the OPNsense model, configd and templates. Runtime JSON is root-owned with mode 0600; secrets are absent from process arguments.

The model stays at `OPNsense/Newt` in config.xml, preserving the local 1.0 plugin's settings. First-time model migration imports valid standalone JSON settings. Invalid legacy settings are not imported, and their contents are never logged.

The daemon port owns `/usr/local/bin/newt` and the rc service. A supervisor restarts a crashed child. The port disables automatic executable replacement so upgrades belong to pkg. Service status confirms the local daemon; Pangolin reports tunnel connectivity.

## Build in a FreeBSD/OPNsense build environment

Copy the proposed daemon port into a complete ports checkout:

```sh
cp -R freebsd/net/pangolin-newt /usr/ports/net/
make -C /usr/ports/net/pangolin-newt makesum stage check-plist package
```

Go 1.26 or newer builds the daemon from source using the standard ports Go framework. Install the resulting dependency in the **build environment**, then copy the plugin into the current plugins checkout:

```sh
cp -R opnsense/security/newt /usr/plugins/security/
make -C /usr/plugins/security/newt lint style package
```

An adjacent OPNsense core checkout supplies the official rules. `sh build.sh /path/to/opnsense/plugins` is a convenience wrapper and refuses to overwrite an existing plugin directory. The plugin contains no downloaded executable, custom package manifest or binary-fetching install hook. `Mk/plugins.mk` generates package metadata and lifecycle hooks.

## Checks

```sh
PHPCS_BIN=/path/to/phpcs tools/check.sh /path/to/opnsense/core
```

Requires PHP with XML extensions, PHP_CodeSniffer, xmllint, ShellCheck, Python 3 and Jinja2. Run `php tests/model.php` on OPNsense as well. See [VALIDATION.md](VALIDATION.md) for evidence and remaining checks. A clean poudriere build against intended supported branches is still required before submission.

## Contribution and licensing

The proposed maintainer is `mail@soehnke.de`; the human contributor must confirm ongoing maintainership and review the implementation before submitting. See [the checklist](docs/upstream/CHECKLIST.md). Drafts have not been posted upstream. The previous standalone binary bundle is retained in release `v1.0`.

The master plugin framework produces `os-newt-devel-1.1.pkg` by default. Transitioning from the old combined package requires first removing `os-newt` (after a configuration backup), then installing the separate daemon and plugin packages. The saved config.xml model is retained. Do this on a test system first; it briefly interrupts the connection. Do not force conflicting file ownership or bypass dependency checks.

Integration code: BSD-2-Clause, see LICENSE. Newt: independently AGPLv3 licensed, distributed as a separate dependency. Newt implementation code must not be copied into the plugin.

**AI disclosure:** OpenAI Codex (GPT-6) assisted development and review preparation. A human contributor must understand, review and maintain submitted changes.

References: [OPNsense contribution rules](https://github.com/opnsense/plugins/blob/master/CONTRIBUTING.md), [MVC/coding guidance](https://docs.opnsense.org/development/examples/helloworld.html), [FreeBSD Go ports](https://docs.freebsd.org/en/books/porters-handbook/special/#using-go).
