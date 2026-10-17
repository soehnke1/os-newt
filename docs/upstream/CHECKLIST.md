# Upstream checklist

## Implemented

- Standard plugin Makefile and pkg-descr, using `../../Mk/plugins.mk`.
- `PLUGIN_DEPENDS=pangolin-newt`; no executable, binary bundle or executable download in the plugin.
- Separate source port with `USES=go:1.26+,modules`, source checksums, AGPLv3 metadata, rc service and private sample configuration.
- Port patch prevents binary self-replacement; pkg owns daemon updates.
- BSD-2-Clause headers, OPNsense PSR-12+ style, model constraints, ACL/menu, configd, templates and service registration.
- Framework migration replaces the custom configuration-writing installer; existing model/API paths remain compatible.
- Tests cover conditional credentials, invalid settings, JSON escaping and optional fields.
- Submission drafts disclose AI tool and model.

## Required before submission

1. Human contributor confirms maintainer address/responsibility, reviews licensing and understands the code.
2. Open the preliminary discussion issue in opnsense/plugins and allow time for feedback. `discussion.md` is a draft, not a posted issue.
3. Obtain acceptance of the daemon in FreeBSD ports. The proposal in this repository does not itself satisfy OPNsense's dependency requirement.
4. Ensure availability in the OPNsense ports/build branch selected by its maintainers.
5. Refresh against current opnsense/plugins master and rerun checks.
6. Run clean poudriere/target-branch builds and install/upgrade/remove, boot and connectivity tests on a disposable VM.
7. After discussion and dependency readiness, the human contributor can submit the plugin PR using `plugin-pr.md`.

The repository remains private. Preparation does not replace the operational firewall installation.

Policy: https://github.com/opnsense/plugins/blob/master/CONTRIBUTING.md
