# Code Review Rules

## Scope
Applies to Terraform (`.tf`, `.tfvars`), Python (Lambda handlers, Strands agents, helper scripts), and Bash (`tf-wrapper.sh`, `auth-otel.sh`, onboarding scripts) in this repo.

## General Principles
- Prefer clarity over cleverness. If a reviewer needs to ask "what does this do?", it needs a comment or a rename.
- Every PR should be reviewable in under 15 minutes. If a diff is bigger than that, ask the author to split it.
- Flag any change that silently alters behavior for existing environments (dev/staging/prod) without a corresponding `tfvars` or config update.

## Terraform-Specific
- **State & backend**: Any change to `backend.tf` (bucket, key, lock mechanism) must be called out explicitly in the PR description — these changes require manual `terraform init -reconfigure` or migration steps for every consumer.
- **Locking mechanism consistency**: If a module uses `use_lockfile = true`, don't reintroduce `dynamodb_table` in the same or sibling configs — pick one locking strategy per state file and keep it consistent across environments.
- **`prevent_destroy`**: Any resource holding state, secrets, or long-lived infra (S3 state bucket, DynamoDB tables, KMS keys) should have `lifecycle { prevent_destroy = true }` unless there's a documented reason not to.
- **No hardcoded ARNs/account IDs**: Use data sources (`data.aws_caller_identity.current.account_id`) or variables instead of literal account IDs, bucket names, or ARNs baked into `.tf` files.
- **Provider version pinning**: Confirm `.terraform.lock.hcl` is committed alongside any provider version bump; don't let a PR silently widen a version constraint.
- **tfvars hygiene**: Check for syntax issues (unterminated strings, missing commas) before merge — these fail silently until `plan`/`apply` time. Confirm `default_tags` are applied consistently across environments.

## Python-Specific
- **Bedrock/Strands calls**: Confirm no deprecated parameters (e.g. `temperature` alongside extended-thinking `Opus` models) and that `guardrail_config` is passed where required by policy.
- **Token/credential handling**: No credentials, JWTs, or Bearer tokens logged, printed, or committed — even in debug branches. Check for `print(token)`-style leftovers.
- **Error handling on external calls**: GCP Pub/Sub, AWS Bedrock, and Jira MCP calls should have explicit timeout and retry/backoff logic, not bare `try/except: pass`.

## MCP / Claude Code Config
- **`.mcp.json` / `settings.local.json` changes**: Review `headersHelper` and `otelHeadersHelper` script changes carefully — these generate auth tokens; a bug here can silently break auth for the whole team, not just the author.
- **Env var and secret references**: Confirm no static tokens are checked in as fallback values in `headersHelper`-style scripts.

## Review Checklist (paste into PR template)
- [ ] `terraform fmt -check` and `terraform validate` pass
- [ ] No hardcoded secrets, account IDs, or ARNs
- [ ] Backend/locking changes called out explicitly, if any
- [ ] tfvars files are valid HCL (no unterminated strings)
- [ ] Python changes pass linting (`ruff`/`black`) and have basic error handling on external calls
- [ ] Any MCP/auth config change tested with a fresh `/mcp` reconnect
