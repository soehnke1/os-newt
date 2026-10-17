# Validation of the upstream preparation

Date: 2026-10-17. Target: OPNsense 26.7.6_3 / FreeBSD 15.1-RELEASE-p4 / amd64.
Exact framework revisions are recorded in `docs/upstream/baselines.json`.

## Passed

- PHP_CodeSniffer with the unmodified OPNsense core PSR12+ ruleset: no errors or warnings. The migration class uses a single documented suppression for OPNsense's required `M1_0_0` naming convention.
- PHP syntax, XML parsing and ShellCheck.
- Native `make lint` using the OPNsense plugins/core framework snapshots.
- OPNsense/Phalcon model tests: valid settings, invalid endpoint/MTU/port/DNS/site ID, empty optional fields, disabled configuration and required credentials when enabled.
- Jinja2 template tests: JSON escaping, correctly typed MTU/port, optional fields and activation.
- Patched Newt source cross-built for FreeBSD and executed there with `--version`.
- Native FreeBSD port fetch/checksum, extract, vendor, patch, source build, staging, `check-plist` and package creation using the ports framework.
- Portlint `-AC`: looks fine, using a clean port fixture and the full relevant framework/dependency metadata.
- OPNsense plugin package built by `Mk/plugins.mk`; its manifest depends on `pangolin-newt-1.18.1` and it contains no daemon binary.
- Source port package sample configuration has root ownership and mode 0600.

The native source build used a verified standalone Go 1.26.9 compiler with explicit tool paths and dependencies already supplied in the build environment. Plugin dependency lookup used a separate temporary package registry containing the actual built port manifest. Neither package was installed over the running firewall.

## Still required

- Clean poudriere builds on the target supported branch(es).
- Fresh install, standalone removal/rollback, reboot and client-connectivity tests on a disposable OPNsense VM. The live upgrade checks below do not replace these remaining checks.
- Human maintainer review/commitment, acceptance of the FreeBSD port, dependency availability in OPNsense and the required preliminary discussion.

## Live upgrade test, 2026-10-17

On the target OPNsense 26.7.6_3 / FreeBSD 15.1-RELEASE-p4 / amd64 firewall, the operator-authorized upgrade from the installed combined `os-newt-1.0` package to the v1.1-rc1 artifacts was performed:

- Saved the original `config.xml`, runtime JSON, rc configuration and v1.0 rollback package in a root-only directory before removing the old package.
- Verified SHA256 agreement between the transferred candidate packages and the local build artifacts.
- Removed `os-newt-1.0`, installed `pangolin-newt-1.18.1` and `os-newt-devel-1.1` without forced ownership or dependency overrides. All package hooks completed, templates reloaded and Newt started automatically.
- Immediately after installation, the runtime JSON matched the backup, and the saved site secret was preserved. Runtime directory/file permissions were root:wheel 0700/0600.
- Authenticated to the actual WebUI through an SSH forward. The settings page returned HTTP 200 with a password input for the secret. The settings and service APIs returned valid responses.
- Changed log level to WARN using the settings API, applied it, verified persistence, then restored the original DEBUG setting and applied it. Both saves returned `saved`; both reconfigurations returned `ok`. Runtime JSON again matched the original backup after restoration.
- Exercised the service overview's own stop, start and restart APIs. Each returned `ok`; Newt's status API reported `stopped` after stop and `running` after start/restart. The core service list included `Pangolin Newt` with `running: 1`.
- Confirmed the site returned online in the Pangolin database and reported Newt 1.18.1. The existing internal HTTP target was reachable from the firewall before and after the upgrade.
- `pkg check -ds os-newt-devel pangolin-newt` completed successfully. The configured endpoint, site credentials and network settings remained unchanged. A subsequent settings API write changed the log level to INFO after the test had restored DEBUG; the later setting was left in place.

The candidate remains installed. No firewall reboot or uninstall/rollback was performed. Authenticated HTTP/API checks exercise the WebUI backend; no interactive browser rendering test was performed. Reachability from the firewall and the site's online state do not prove end-to-end iPhone connectivity; that check awaits operator confirmation.

This preparation is not a claim of upstream acceptance or release certification.
