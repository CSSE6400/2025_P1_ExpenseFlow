# ADR 04

## Backend Tooling

This ADR relates to how the backend tooling was chosen.

## Importance

This is imprortant as it can affect the development process of the backend.

## Options

- No tooling
- Basic formatter
- All best in class tooling (Mypy, Ruff Lint, Ruff Format, UV)

## Comparison

No tooling

- no setup required
- very little developer feedback
- hard to pickup on mistakes or better ways to do things

Basic formatters

- very little setup required
- keeps code somewhat readable
- code can still have errors
- dependency management is difficult

All Tooing

- takes time to setup
- Keeps code readable
- Can reduce typing errors (static type analysis with Mypy)
- UV as dependency management tool simplifies the process
- Linting keeps the code readable and up to various PEP standards

## Chosen Outcome

All the tooling
