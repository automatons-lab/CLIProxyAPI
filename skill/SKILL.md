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

## Build & Run

```bash
cd ~/repos/CLIProxyAPI
go build -o cli-proxy-api ./cmd/server    # Build
go run ./cmd/server --config config.yaml  # Dev
go test ./...                             # Tests
gofmt -w .                                # Format (required after changes)
go build -o test-output ./cmd/server && rm test-output  # Verify compile (REQUIRED)
```

## Our deployment

All LLM calls route through `http://127.0.0.1:31337/v1`. Clients use `openai` Python/Go SDK. Models specified as `anthropic/claude-sonnet-4-6` — CLIProxy translates to provider-native format. Tool-use and Anthropic-specific headers (prompt caching) are passed through.

## Architecture & code conventions

Read `AGENTS.md` in the repo root — contains directory map, code rules, and constraints.

For config reference: `config.example.yaml`.
