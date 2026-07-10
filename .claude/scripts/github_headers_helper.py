#!/usr/bin/env python3
"""
Outputs {"Authorization": "Bearer <GITHUB_PAT>"} as JSON to stdout.
Called by Claude Code as a headersHelper before each MCP connection.

Resolution order:
  1. .env file in the project root — plain KEY=VALUE format, no variable expansion
  2. Process environment — fallback if already set
"""
import json
import os
import sys
from pathlib import Path

_PROJECT_ROOT = Path(__file__).parent.parent.parent  # scripts/ → .claude/ → project root
_ENV_FILE = _PROJECT_ROOT / ".env"


def _from_env_file():
    if not _ENV_FILE.exists():
        return None
    with _ENV_FILE.open() as f:
        for line in f:
            line = line.strip()
            if line.startswith("#") or "=" not in line:
                continue
            key, _, value = line.partition("=")
            if key.strip() == "GITHUB_PAT":
                return value.strip().strip('"').strip("'")
    return None


def main():
    token = _from_env_file() or os.environ.get("GITHUB_PAT")

    if not token:
        print(
            "GITHUB_PAT not found. Add it to .env or set it in the environment.",
            file=sys.stderr,
        )
        sys.exit(1)

    print(json.dumps({"Authorization": f"Bearer {token}"}))


if __name__ == "__main__":
    main()
