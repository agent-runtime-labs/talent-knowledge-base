# Writing Rules

## Scope
Applies to commit messages, PR descriptions, `CLAUDE.md` / README documentation, runbooks, and inline comments.

## Commit Messages
- Format: `<type>(<scope>): <summary>` — e.g. `fix(backend): correct use_lockfile boolean in dev backend.tf`
- Types: `feat`, `fix`, `chore`, `docs`, `refactor`, `security`.
- Summary line under 72 chars, imperative mood ("add", not "added" or "adds").
- Body (if needed): explain *why*, especially for infra changes — link to the incident, ticket, or reasoning, not just what changed.

## PR Descriptions
Structure every PR description with:
1. **What changed** — one or two sentences.
2. **Why** — the problem this solves (link ticket/incident if applicable).
3. **Impact** — which environments/services are affected; call out anything requiring manual action post-merge (e.g. `terraform init -reconfigure`, `/mcp` reconnect, secret rotation).
4. **Testing** — how this was validated (`plan` output, local test run, staging deploy).

Skip filler like "minor fix" or "small update" as the entire description — reviewers need enough context to review without pulling the author aside.

## Documentation (`CLAUDE.md`, READMEs, runbooks)
- Lead with the "why" of the project/module before the "how" — one paragraph of context before diving into setup steps.
- Use numbered steps for anything sequential (setup, deployment, auth flow); use bullets only for unordered facts.
- Every documented workaround should state: the symptom, the root cause (if known), and the fix — not just the fix. Future readers need to know when the workaround is still needed and when it's safe to remove.
- Keep command examples copy-pasteable: full flags, no placeholder ambiguity unless intentionally parameterized (and mark those clearly, e.g. `<env>`, `${PROJECT_ID}`).
- Cross-cloud or cross-service flows (Azure AD → AWS Bedrock → GCP Pub/Sub) should include a short diagram or ordered list of hops — don't make the reader reconstruct the flow from prose.

## Tone
- Direct and factual. Avoid hedging language ("might possibly maybe") in runbooks and incident docs — state what is known, what is uncertain, and what to check next.
- No marketing language in internal docs ("seamlessly," "powerful," "cutting-edge") — describe what the system does and its actual constraints.
- When documenting a limitation (e.g. "`headersHelper` not re-invoked on token expiry mid-session"), state the limitation plainly and the current workaround — don't soften it into a footnote.

## Comments in Code
- Explain intent and constraints, not mechanics the code already shows.
- Reference tickets/incidents for non-obvious fixes: `# see INFRA-482 — gRPC transport silently drops otelHeadersHelper output`.
