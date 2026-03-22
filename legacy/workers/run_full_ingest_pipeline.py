import subprocess
import sys
from pathlib import Path


BASE_DIR = Path(r"C:\MatchMatrix-platform\workers")
PYTHON_EXE = r"C:\Python314\python.exe"

EXECUTOR_SCRIPT = BASE_DIR / "run_scheduler_queue_executor_v2.py"
PARSER_SCRIPT = BASE_DIR / "run_payload_parser.py"


def run_python_script(script_path: Path) -> tuple[bool, str]:
    cmd = [PYTHON_EXE, str(script_path)]

    result = subprocess.run(
        cmd,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )

    stdout = (result.stdout or "").strip()
    stderr = (result.stderr or "").strip()

    output_parts = []
    if stdout:
        output_parts.append(stdout)
    if stderr:
        output_parts.append(stderr)

    output = "\n".join(output_parts).strip()
    if not output:
        output = f"Process finished with code {result.returncode}"

    return result.returncode == 0, output


def main() -> None:
    print("=== MATCHMATRIX FULL INGEST PIPELINE ===")
    print()

    if not EXECUTOR_SCRIPT.exists():
        print(f"Chyba: chybí soubor {EXECUTOR_SCRIPT}")
        sys.exit(1)

    if not PARSER_SCRIPT.exists():
        print(f"Chyba: chybí soubor {PARSER_SCRIPT}")
        sys.exit(1)

    print("[1/2] Spouštím queue executor...")
    ok_executor, out_executor = run_python_script(EXECUTOR_SCRIPT)
    print(out_executor)
    print()

    if not ok_executor:
        print("Pipeline skončila chybou v queue executoru.")
        sys.exit(1)

    print("[2/2] Spouštím payload parser...")
    ok_parser, out_parser = run_python_script(PARSER_SCRIPT)
    print(out_parser)
    print()

    if not ok_parser:
        print("Pipeline skončila chybou v payload parseru.")
        sys.exit(1)

    print("=== PIPELINE DONE ===")


if __name__ == "__main__":
    main()