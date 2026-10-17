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
- Candidate package install/upgrade/remove, reboot, WebUI/API and client-connectivity tests on a disposable OPNsense VM. The earlier v1.0 live integration tests do not substitute for these candidate tests.
- Human maintainer review/commitment, acceptance of the FreeBSD port, dependency availability in OPNsense and the required preliminary discussion.

This preparation is not a claim of upstream acceptance or release certification. The live v1.0 package remains in place.
