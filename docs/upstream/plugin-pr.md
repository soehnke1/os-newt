Title: security/newt: add Pangolin site connector integration

Pangolin Newt currently needs manual configuration and service management on OPNsense. This plugin adds a single-site MVC/API settings page, standard service controls and a log view. Resource definitions and access policies remain on the Pangolin server.

The plugin depends on pangolin-newt and contains no daemon executable. Its binary is built independently from source, with automatic executable replacement disabled. The model and templates own persistent/runtime settings. A first-time migration imports valid standalone settings without replacing existing plugin configuration.

Fill in before submission:

- Preliminary discussion URL.
- Accepted FreeBSD port and OPNsense branch availability.
- Intended supported branches and clean build results.
- Install/upgrade/remove, boot and client-connectivity results.
- Confirmed human maintainer name/email.

AI disclosure: OpenAI Codex (GPT-6) assisted development. The human submitter must review and understand the changes and accept maintainership. This is a draft, not a submitted PR.
