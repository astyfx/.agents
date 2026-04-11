# Python3 Command Line Tools Bootstrap Stub

## Symptom

- A shell command that invokes `python3` fails with an Xcode Command Line Tools
  bootstrap message instead of running Python.
- Example failure:
  - `xcode-select: error: No developer tools were found ...`

## Affected Surfaces

- `scripts/new-task.sh` before the 2026-04-07 reboot slice
- any local script that assumes `/usr/bin/python3` is usable on a fresh macOS
  machine

## Root Cause

On some macOS setups, `/usr/bin/python3` is only a bootstrap stub that asks for
Command Line Tools installation. Scripts that silently depend on it will fail
even for simple text manipulation.

## Workaround

- Avoid `python3` for simple harness text updates when shell tools are enough.
- If Python is truly required, fail with a clear prerequisite message.

## Durable Fix

- `scripts/new-task.sh` now updates `work-handoff.md` using `awk` and
  shell instead of `python3`.

## Follow-Up

- Audit other harness scripts that still assume a working `python3`.
- Prefer shell-native implementations for lightweight scaffolding paths.
