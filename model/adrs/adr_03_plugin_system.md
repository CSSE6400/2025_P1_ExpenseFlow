# ADR 03

## Plugin System

This ADR relates to how the plugin system works in ExpenseFlow.

## Importance

This is important as ExpenseFlow is using a microkernel architecture and requires plugins.

## Options

- Static Plugin System
- Dynamic Plugin System

## Comparison

Statically loaded plugin system

- easier to implement
- No need to implement wayts to load plugins at runtime
- No need to implement ways to fetch plugins (as they are included in the compiled artefact)
- More secure as malicious plugins are forced to be evaluated and looked at during compile time
- Not very flexible though

Dynamically loaded plugin system

- Harder to implement
- More flexible
- Need to implement some sort of standard for loading and fetching plugins
- Security risks of who can load and what plugins can be loaded

## Chosen Outcome

Statically loaded plugin system
