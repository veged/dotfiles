# Unified MCP Registry Design

## Summary

This document defines a single source of truth for MCP servers across supported AI tools in this repository.

The goal is to keep MCP server definitions in `dotfiles`, leave secrets in environment variables or keychain-backed exports, and generate tool-specific configs during installation instead of maintaining parallel hand-written registries.

## Problem

The repository currently manages multiple AI tools, but MCP configuration is split across tool-specific files:

- `codex/config.toml`
- `cursor/mcp.json`
- `config/opencode/opencode.jsonc`
- `claude/settings.json` allowlists for `mcp__...` tools

This creates drift risk:

- a server can exist for one client and be missing for another
- permissions can reference tools that are not actually configured
- local MCP binaries can exist on disk without any declarative install path
- instructions can depend on MCP servers that are absent from the active client config

## Goals

- Keep the MCP server list in a single declarative file in `dotfiles`
- Support multiple AI clients from the same registry
- Keep secrets out of the repository
- Install local MCP runtimes declaratively
- Generate client-specific MCP config at install time
- Make drift detectable with a dedicated check mode

## Non-Goals

- Replacing each client's full config format with a universal one
- Storing secrets in the registry
- Solving plugin, skill, or instruction sync in the same layer
- Supporting arbitrary per-machine MCP differences beyond environment-driven configuration

## Source Of Truth

The canonical registry lives in:

- `ai/mcp.json`

This file follows the same repository-level pattern as:

- `ai/skills/skills.json`
- `ai/plugins/plugins.json`

The registry describes MCP servers in a neutral format that can be adapted to each client.

## Registry Shape

The exact field set can evolve, but the first version should support these concepts:

- server name
- transport kind: local command or remote URL
- local command and argument list
- remote URL
- environment variable references by name
- enabled flag
- installation metadata for local runtimes
- optional client-specific overrides when a target format needs special handling

Illustrative shape:

```json
{
  "fff": {
    "type": "local",
    "enabled": true,
    "command": "/Users/veged/.local/bin/fff-mcp",
    "args": [],
    "install": {
      "kind": "binary",
      "path": "/Users/veged/.local/bin/fff-mcp"
    }
  },
  "sourcecraft": {
    "type": "remote",
    "enabled": true,
    "url": "https://api.sourcecraft.tech/mcp",
    "env": {
      "bearerToken": "SOURCECRAFT_PAT"
    }
  }
}
```

This is intentionally repository-oriented, not client-oriented.

## Generated Outputs

`./scripts/install-mcp` reads `ai/mcp.json` and materializes MCP-related configuration for each supported client.

### Codex

Target:

- `~/.codex/config.toml`

Behavior:

- render the final file from a repository template plus generated MCP entries
- render local servers as `command`
- render remote servers as `url` plus env-backed auth fields

Design constraint:

- `dotfiles/codex/config.toml` must stop being linked directly as the live target file
- the repository should keep a template source for non-MCP Codex settings, and `install-mcp` should materialize the final `~/.codex/config.toml`

### Cursor

Target:

- `~/.cursor/mcp.json`

Behavior:

- generate `mcpServers`
- map remote auth headers from env references
- map local command-based servers to Cursor's `command` and `args` format

### OpenCode

Target:

- `~/.config/opencode/opencode.jsonc`

Behavior:

- render the final file from a repository template plus generated MCP entries
- map local servers to OpenCode's command array format
- map remote servers to `type: "remote"` entries with env-backed headers where supported

### Claude

Target:

- `~/.claude/settings.json`

Behavior:

- render the final file from a repository template plus MCP-derived permissions
- if Claude later gains or uses a dedicated MCP registry file in this setup, generate that from the same source too

Important limitation:

- Claude is currently special because the visible repository config contains allowlists for `mcp__...` tools rather than a standalone MCP registry file
- the generator must treat Claude as a derived target, not as the canonical definition

## Installation Flow

Single entrypoint:

- `./scripts/install-mcp`

Default behavior:

- ensure required local MCP runtimes are installed
- render client-specific MCP config from `ai/mcp.json`

Recommended modes:

- `./scripts/install-mcp`
- `./scripts/install-mcp --tools-only`
- `./scripts/install-mcp --sync-only`
- `./scripts/install-mcp --check`

`install.conf.yaml` should call `./scripts/install-mcp` as part of bootstrap after base package installation.

## Template Strategy

Generated outputs should not be written back into repository source files.

For clients whose live files also contain non-MCP settings, the repository should keep template sources and materialize final files into the home directory during install.

This applies to:

- Codex
- Claude
- OpenCode

For a client with a dedicated MCP-only file, the repository can keep only the source registry and generate the target file directly.

This applies to:

- Cursor

Operational consequence:

- Dotbot should stop linking live config files that are now generated outputs
- `install-mcp` becomes responsible for writing those files after template expansion

## Local Runtime Installation

`ai/mcp.json` should also declare how local MCP runtimes are expected to exist.

For the first version, keep this narrow and explicit:

- local binaries installed to stable user paths
- remote MCP servers require no runtime install

For `fff`, the repository should declare both:

- it is a local MCP server
- the expected executable path used by generated configs

The install step is responsible for making that path real on a new machine.

## Drift Model

The repository should treat `ai/mcp.json` as the only editable MCP registry.

Generated outputs are materialized during install, not manually edited in the repository.

`./scripts/install-mcp --check` should fail if:

- a required local executable is missing
- a generated config differs from the current materialized one
- a supported target cannot represent a configured server

This gives a fast sanity check for bootstrap regressions.

## Path Strategy

Machine-facing config files should be generated at install time rather than committed as generated artifacts.

Reasons:

- avoids drift between source and generated files
- avoids committing machine-specific paths where a generator can normalize them
- keeps the repository focused on source definitions and transformation logic

This means MCP sections and any MCP-derived permission blocks in tool-specific configs become derived state.

## Security Model

Secrets remain outside the repository.

Allowed patterns:

- environment variable references in generated config
- shell environment exports backed by keychain or local secret bootstrap

Disallowed patterns:

- raw tokens in `ai/mcp.json`
- raw tokens in generated repository files

## Assumptions

- `dotfiles` should own the full shared MCP server list across AI tools
- per-machine variance should be minimal and driven by environment, not by separate config files
- current clients can tolerate generated MCP sections or fully generated MCP config files
- `fff` is representative of the local-binary MCP case that this design must support

## Risks

- client formats are not isomorphic, so some registry fields will need target-specific adapters
- partial-file generation is more fragile than whole-file generation if surrounding formats evolve
- Claude may require extra handling because permissions and MCP availability are coupled indirectly
- absolute executable paths can still be machine-sensitive if installation conventions change

## Recommended Rollout

1. Add `ai/mcp.json` with the current shared MCP inventory
2. Split mixed client configs into repository templates plus generated live outputs
3. Implement `./scripts/install-mcp` with `sync` and `check` modes first
4. Migrate Codex, Cursor, and OpenCode to generated MCP config
5. Derive Claude MCP-related permissions from the same source
6. Add local runtime installation for `fff`
7. Wire `./scripts/install-mcp` into `install.conf.yaml`
8. Remove hand-maintained MCP duplication from repository configs

## Open Questions Resolved In This Design

- Canonical format: JSON
- Canonical path: `ai/mcp.json`
- Entry point script: `./scripts/install-mcp`
- Generated artifacts: materialized during install, not committed as source
- Secrets: environment variables or keychain-backed exports only
