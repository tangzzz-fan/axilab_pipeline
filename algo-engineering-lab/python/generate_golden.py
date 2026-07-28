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


def cmd_fir_ppg(_: argparse.Namespace) -> int:
    from .generate_fir_ppg import main as gen_main

    return gen_main()


def cmd_hrv_freq_domain(_: argparse.Namespace) -> int:
    from .generate_hrv_freq_domain import main as gen_main

    return gen_main()


def cmd_coreml_quant(_: argparse.Namespace) -> int:
    from .generate_coreml_quant import main as gen_main

    return gen_main()


def cmd_streaming_fir(_: argparse.Namespace) -> int:
    from .generate_streaming_fir import main as gen_main

    return gen_main()


def cmd_hrv_artifact_correction(_: argparse.Namespace) -> int:
    from .generate_hrv_artifact_correction import main as gen_main

    return gen_main()


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(prog="generate_golden")
    sub = parser.add_subparsers(dest="cmd", required=True)
    sub.add_parser("doctor", help="Verify uv env imports")
    sub.add_parser("hrv_time_domain", help="Generate Case1 HRV time-domain golden set")
    sub.add_parser("fir_ppg", help="Generate Case2 FIR PPG golden + C coeffs header")
    sub.add_parser("hrv_freq_domain", help="Generate Case3 HRV frequency-domain golden + snapshots")
    sub.add_parser("coreml_quant", help="Generate Case4 CoreML FP32/FP16 compare report")
    sub.add_parser("streaming_fir", help="Generate Case5 streaming FIR / packet-loss golden")
    sub.add_parser("hrv_artifact_correction", help="Generate Case6 HRV artifact-correction golden")
    args = parser.parse_args(argv)
    if args.cmd == "doctor":
        return cmd_doctor(args)
    if args.cmd == "hrv_time_domain":
        return cmd_hrv_time_domain(args)
    if args.cmd == "fir_ppg":
        return cmd_fir_ppg(args)
    if args.cmd == "hrv_freq_domain":
        return cmd_hrv_freq_domain(args)
    if args.cmd == "coreml_quant":
        return cmd_coreml_quant(args)
    if args.cmd == "streaming_fir":
        return cmd_streaming_fir(args)
    if args.cmd == "hrv_artifact_correction":
        return cmd_hrv_artifact_correction(args)
    return 1


if __name__ == "__main__":
    sys.exit(main())
