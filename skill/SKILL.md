---
name: project-cliproxyapi
description: "Work with CLIProxyAPI project. Use when building, debugging, configuring, or modifying CLIProxyAPI — Go proxy server providing OpenAI/Gemini/Claude/Codex compatible API endpoints with OAuth, round-robin load balancing, and multi-provider routing. Also use when troubleshooting LLM API calls that route through CLIProxy."
---

# CLIProxyAPI

- **Repo**: `router-for-me/CLIProxyAPI` (upstream)
- **Local**: `~/repos/CLIProxyAPI`
- **Port**: 31337 (our deployment)
- **Language**: Go 1.26+
- **Config**: `config.yaml` (template: `config.example.yaml`)
- **Auth dir**: `auths/` (OAuth tokens, session data)

## What it does

Proxy server that exposes OpenAI-compatible `/v1/chat/completions` (and other endpoints) while routing to multiple backend providers: Anthropic Claude, Google Gemini, OpenAI, Codex, Qwen, iFlow. Handles OAuth flows, round-robin load balancing across accounts, and protocol translation.

Our deployment routes all LLM calls from feed-gathering and other services through `http://127.0.0.1:31337/v1`.

## Build & Run

```bash
cd ~/repos/CLIProxyAPI
go build -o cli-proxy-api ./cmd/server
./cli-proxy-api --config config.yaml
```

Dev mode:
```bash
go run ./cmd/server --config config.yaml
```

## Key commands

```bash
gofmt -w .                               # Format (required after Go changes)
go build -o cli-proxy-api ./cmd/server    # Build
go test ./...                             # All tests
go build -o test-output ./cmd/server && rm test-output  # Verify compile (REQUIRED after changes)
```

## Architecture

| Directory | Purpose |
|---|---|
| `cmd/server/` | Entrypoint |
| `internal/api/` | Gin HTTP API (routes, middleware, modules) |
| `internal/translator/` | Provider protocol translators. **Do not modify standalone** — only as part of broader changes |
| `internal/runtime/executor/` | Per-provider runtime executors (Codex WebSocket, etc.) |
| `internal/thinking/` | Thinking/reasoning token processing |
| `internal/registry/` | Model registry + remote updater |
| `internal/store/` | Storage backends (file, Postgres, git, object store) |
| `internal/config/` | Config loading and validation |
| `internal/cache/` | Request signature caching |
| `internal/watcher/` | Config hot-reload |
| `internal/usage/` | Token accounting |
| `internal/tui/` | Terminal UI (`--tui`) |
| `sdk/cliproxy/` | Embeddable Go SDK |

## Code rules (from AGENTS.md)

- KISS. Small changes.
- English comments only. Translate non-English comments if editing.
- `gofmt` + goimports-style imports.
- No `log.Fatal` — return errors, log via logrus.
- Wrap defer errors. Avoid shadowed variables.
- No timeouts after upstream connection established (specific exceptions listed in AGENTS.md).
- `internal/translator/` edits: only alongside broader changes, or file an issue.
- `internal/runtime/executor/` — executors + unit tests only; helpers go in `helps/`.

## Config

Key sections in `config.yaml`:
- `host` / `port` — bind address
- `api-keys` — auth keys for clients
- `auth-dir` — OAuth token storage path
- `remote-management` — management API settings
- Provider sections: claude, gemini, openai accounts + round-robin

Full reference: `config.example.yaml`

## Our deployment specifics

- Runs on `127.0.0.1:31337`
- Used by: feed-gathering (digest system), OpenClaw agents
- Client calls use `openai` SDK pointed at `http://127.0.0.1:31337/v1`
- Models specified as `anthropic/claude-sonnet-4-6`, CLIProxy translates to provider-native format
- Tool-use / function calling passed through to providers
- Anthropic-specific headers (prompt caching) forwarded via `extra_headers`
