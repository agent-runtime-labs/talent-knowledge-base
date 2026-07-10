# Code Style Rules

## Terraform
- Run `terraform fmt` before every commit — no exceptions, no manually-aligned `=` signs.
- File layout per module: `main.tf`, `variables.tf`, `outputs.tf`, `backend.tf`, `provider.tf`. Don't dump everything into `main.tf`.
- Resource naming: `<resource_type>.<project>_<purpose>`, e.g. `aws_dynamodb_table.sre_hub_locks`, not `aws_dynamodb_table.table1`.
- Variables: snake_case, always with a `description` and, where sensible, a `type` and `default`.
- Tags: every taggable resource gets `default_tags` merged in via the provider block — don't hand-roll tag maps per resource unless there's a resource-specific override.
- Use `for_each` over `count` when iterating over named collections (envs, regions) — `count` index-shifting causes painful diffs.
- Environment-specific values belong in `tfvars`, never hardcoded in `.tf` files, even "temporarily."

## Python
- Formatter: `black`, line length 88 (default). Linter: `ruff`.
- Type hints on all function signatures, especially for Lambda handlers (`def handler(event: dict, context: LambdaContext) -> dict:`).
- Use `@tool` decorated functions (Strands SDK) with clear docstrings — these docstrings often double as the tool description surfaced to the model, so write them for that audience too.
- Prefer `pathlib.Path` over `os.path` string joins.
- Structured logging over `print()` — use the `logging` module with JSON formatting if the output feeds GCP Cloud Logging / Log-based Metrics.
- Config/secrets access: centralize through a single `config.py` or `secrets.py` module; don't scatter `boto3.client("secretsmanager")` calls across files.

## Bash
- `set -euo pipefail` at the top of every script (`tf-wrapper.sh`, `auth-otel.sh`, onboarding scripts).
- Quote all variable expansions: `"$VAR"`, not `$VAR`.
- Prefer explicit long-form flags in scripts meant to be read/maintained by others (`--env` over `-e`) unless brevity is the point (interactive one-liners).
- Any script that resolves environment-specific values (like the `${USER}` substitution workaround) should fail loudly if resolution fails, not silently fall back to a wrong default.

## Naming Conventions (cross-language)
- Environments: `dev`, `staging`, `prod` — no ad-hoc variants (`stage`, `production`, etc).
- Resource/config prefixes should include `project_name` (e.g. `talent-knowledge-base`, `sre-hub`) so resources are traceable across accounts/projects at a glance.

## Comments & Documentation
- Comment *why*, not *what* — the diff already shows what changed.
- Any non-obvious workaround (e.g. token refresh debounce timing, gRPC vs HTTP transport quirks) gets a comment linking to the reason, even briefly: `# otelHeadersHelper output ignored under gRPC; must use http/protobuf`.
