Title: security/newt: discuss a Pangolin Newt integration

I would like to contribute a small MVC/API plugin for the Pangolin Newt site connector. It would configure one site connection, expose standard service controls and provide a log view. Resources and authorization remain in Pangolin.

The plugin would depend on a separate pangolin-newt daemon package. No precompiled binary would be included. A source port is prepared but has not been accepted in FreeBSD ports; this prerequisite must be resolved first.

The integration uses standard plugin packaging, model migration, configd and templates. The daemon port disables binary self-replacement so pkg retains ownership of upgrades.

Is this within the project's desired scope? Are there preferences for package naming, menu placement or supported branches before I pursue the port and a plugin PR?

AI disclosure: OpenAI Codex (GPT-6) assisted development and preparation of this draft. A human contributor must review and own any submission. Maintainer details and test results must be confirmed before posting.
