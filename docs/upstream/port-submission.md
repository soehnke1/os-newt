Title: [NEW PORT] net/pangolin-newt: Userspace WireGuard site connector for Pangolin

The port builds Newt 1.18.1 from its Go module, installs bin/newt, supplies an rc service and root-only sample configuration, and depends on the CA root bundle.

The rc service uses separate supervisor/child pidfiles. Stopping the supervisor prevents intentional stops from restarting the child. A package patch disables executable self-replacement on FreeBSD so upgrades remain under pkg control.

Upstream: https://github.com/fosrl/newt
Source license: AGPLv3
Proposed maintainer: mail@soehnke.de (human confirmation required).

Before posting, attach a patch against current FreeBSD ports including the category Makefile entry, a clean poudriere log for supported targets, lint results and runtime tests. The OPNsense plugin is a separate BSD-2-Clause contribution.

AI disclosure: OpenAI Codex (GPT-6) assisted development and this draft. The human contributor must review and own the submission.
