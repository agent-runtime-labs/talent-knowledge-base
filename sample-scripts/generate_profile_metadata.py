#!/usr/bin/env python3

import json
import shutil
import sys
from pathlib import Path


SOURCE_DIR = Path(sys.argv[1])
DESTINATION_DIR = Path(sys.argv[2])
METADATA_KEY = "profile_category"


def create_metadata_file(profile_file: Path) -> None:
    folder_name = profile_file.parent.name
    metadata_file = profile_file.with_name(f"{profile_file.name}.metadata.json")

    metadata = {
        "metadataAttributes": {
            METADATA_KEY: folder_name,
        }
    }

    metadata_file.write_text(json.dumps(metadata, indent=2) + "\n", encoding="utf-8")


def main() -> None:
    if not SOURCE_DIR.is_dir():
        raise SystemExit(f"Source directory '{SOURCE_DIR}' was not found.")

    if DESTINATION_DIR.exists():
        shutil.rmtree(DESTINATION_DIR)

    shutil.copytree(SOURCE_DIR, DESTINATION_DIR)

    for file_path in DESTINATION_DIR.rglob("*"):
        if file_path.is_file() and not file_path.name.endswith(".metadata.json"):
            create_metadata_file(file_path)


if __name__ == "__main__":
    main()
