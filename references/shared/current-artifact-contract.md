# Current Artifact Contract

> `current-*` is no longer just a current filename. It is a coordinated set of artifacts that belong to one workflow instance (flow). Directory ownership, the registry, and metadata headers together decide whether an artifact is a valid current artifact.

## Goal

- give `current-*` stable instance identity instead of relying on agent memory
- make initialization, completion, activation, archiving, and cleanup scriptable
- let `Brainstorm -> Architect -> Step -> Review` share the same flow
