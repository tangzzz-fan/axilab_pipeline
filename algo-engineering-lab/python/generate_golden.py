"""Golden generation entrypoints. Case modules land in T2+."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path


def _repo_root() -> Path:
    return Path(__file__).resolve().parents[1]


def cmd_doctor(_: argparse.Namespace) -> int:
    import numpy as np
    import scipy

    print(f"numpy={np.__version__} scipy={scipy.__version__}")
    print(f"repo={_repo_root()}")
    print("doctor: ok")
    return 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(prog="generate_golden")
    sub = parser.add_subparsers(dest="cmd", required=True)
    sub.add_parser("doctor", help="Verify uv env imports")
    args = parser.parse_args(argv)
    if args.cmd == "doctor":
        return cmd_doctor(args)
    return 1


if __name__ == "__main__":
    sys.exit(main())
