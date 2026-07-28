"""Golden generation entrypoints."""

from __future__ import annotations

import argparse
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


def cmd_hrv_time_domain(_: argparse.Namespace) -> int:
    from .generate_hrv_time_domain import main as gen_main

    return gen_main()


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(prog="generate_golden")
    sub = parser.add_subparsers(dest="cmd", required=True)
    sub.add_parser("doctor", help="Verify uv env imports")
    sub.add_parser("hrv_time_domain", help="Generate Case1 HRV time-domain golden set")
    args = parser.parse_args(argv)
    if args.cmd == "doctor":
        return cmd_doctor(args)
    if args.cmd == "hrv_time_domain":
        return cmd_hrv_time_domain(args)
    return 1


if __name__ == "__main__":
    sys.exit(main())
