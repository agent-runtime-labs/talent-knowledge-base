# Security Rules

## Secrets & Credentials
- Never commit secrets, tokens, API keys, or connection strings — including in `tfvars`, `.env` files, or code comments "for reference."
- All secrets flow through AWS Secrets Manager or GCP Secret Manager — not environment variables baked into Lambda config, not `settings.local.json` static values.
- `headersHelper` / `otelHeadersHelper` scripts generate tokens dynamically at call time — never cache a generated Bearer token to disk or log it, even for debugging. Redact tokens in any error output.
- If a static fallback token is ever added "temporarily" to unblock local dev, it must be removed before merge — treat this as a blocking review comment, not a nit.

## Authentication & Authorization
- Azure AD tokens: validate JWTs with RS256 + JWKS endpoint verification — never accept an unverified or `alg: none` token, even in dev/test environments.
- Prefer OAuth 2.0 Device Code Flow over client credentials for anything requiring per-user attribution (audit trails, OTEL ingestion) — client credentials collapse identity to a shared service principal and break traceability.
- Multi-tenant GCP access (AgentCore Gateway, WIF): scope tokens per-user by default. Shared service account bypass (e.g. OnCall Assistant) must be an explicit, documented exception — detected via `roles[]` claim, not inferred from other request attributes.
- JWKS/token caches should have a bounded TTL (e.g. 1-hour in-memory cache) — don't cache indefinitely, and don't skip cache invalidation on auth config changes.

## IAM & Least Privilege
- No `*` resource or action in IAM policies for production infra. Scope to specific ARNs and actions.
- DynamoDB, S3, and Secrets Manager access from Lambda should use resource-based policies scoped to the specific table/bucket/secret, not account-wide access.
- Cross-cloud auth (Azure AD → AWS Bedrock, Azure AD → GCP) should go through short-lived token exchange, never long-lived static credentials stored in one cloud to access another.

## Data Handling
- Treat anything passing through Bedrock Guardrails as potentially sensitive — don't bypass `guardrail_config` for internal/"trusted" traffic.
- Email/ticket content (email triage pipeline) may contain PII — ensure S3/DynamoDB storage of this data has encryption at rest (SSE-KMS) and is not broadly readable across the account.
- CloudFront + Lambda@Edge report portals: enforce auth (Azure AD JWT + HttpOnly cookie) before serving any report content — no unauthenticated fallback path, even for "internal-only" reports.

## State & Infra Security
- Terraform state (S3 bucket) must have versioning + encryption enabled and public access fully blocked — this is state, often containing secrets in plaintext.
- State locking (`use_lockfile` or DynamoDB) is a correctness *and* security control — concurrent unlocked applies can corrupt state and cause partial/inconsistent infra changes. Never disable locking to "save time."
- Any `prevent_destroy = true` removal on state/secrets infra requires a second reviewer, not a solo merge.

## Review Triggers (escalate, don't just comment)
- New IAM policy with wildcard actions/resources
- New public S3 bucket or CloudFront distribution without auth
- Any change to token validation logic (JWT verification, JWKS handling)
- Any change that logs, prints, or persists a credential/token
