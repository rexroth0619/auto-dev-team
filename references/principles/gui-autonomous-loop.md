# GUI Autonomous Loop

> Canonical protocol for GUI-capable tasks.

## Default Rule

If a task touches pages, windows, forms, sessions, permissions, or any clickable GUI path, run the GUI validation loop by default.

## Required Behavior

- prepare or refresh `.autodev/current-gui-test.js`
- prefer headed execution for Web GUI
- keep evidence: timeline, screenshot, console, network, page state
- if the case fails: capture, fix, rerun the same case
- do not mark the task complete until the GUI state becomes passed, not executable, user disabled, or manual only
