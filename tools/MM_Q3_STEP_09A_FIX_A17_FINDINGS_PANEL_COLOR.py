# -*- coding: utf-8 -*-
"""
MATCHMATRIX – Q3 STEP 09A – OPRAVA BARVY OKNA A17 NÁLEZŮ

CO:
- Nahrazuje neexistující konstantu PANEL_1 konstantou PANEL_2
  pouze uvnitř metody documentation_show_a17_findings.

K ČEMU:
- Opravuje NameError při otevření okna A17 – detail nálezů.

KDE:
- PC1 aktivní panel.
- PC2 aktivní panel.

JAK:
- Ověří přesnou metodu a očekávaný počet 4 výskytů.
- Zapíše změnu.
- Provede py_compile na obou souborech.
"""

from __future__ import annotations

import os
import py_compile
import tempfile
from pathlib import Path


TARGETS = [
    Path(
        r"C:\MatchMatrix-Platform\tools"
        r"\matchmatrix_control_panel_V20_1_Q3_DOCUMENTATION_WORKFLOW.py"
    ),
    Path(
        r"\\192.168.3.119\matchmatrix\tools"
        r"\matchmatrix_control_panel_V20_1_Q3_DOCUMENTATION_WORKFLOW.py"
    ),
]

METHOD_START = "    def documentation_show_a17_findings(self):\n"
METHOD_END = "    def open_matchmatrix_path(self, relative_path):\n"


def read_source(path: Path):
    raw = path.read_bytes()
    has_bom = raw.startswith(b"\xef\xbb\xbf")
    if has_bom:
        raw = raw[3:]
    text = raw.decode("utf-8")
    newline = "\r\n" if "\r\n" in text else "\n"
    return text.replace("\r\n", "\n"), has_bom, newline


def patch_source(source: str) -> str:
    start = source.find(METHOD_START)
    if start < 0:
        raise RuntimeError("Nebyla nalezena metoda documentation_show_a17_findings.")

    end = source.find(METHOD_END, start)
    if end < 0:
        raise RuntimeError("Nebyl nalezen konec metody A17 nálezů.")

    method = source[start:end]
    count = method.count("PANEL_1")

    if count == 0 and method.count("PANEL_2") >= 4:
        return source

    if count != 4:
        raise RuntimeError(
            f"Očekávány 4 výskyty PANEL_1 v metodě, nalezeno {count}."
        )

    method = method.replace("PANEL_1", "PANEL_2")
    return source[:start] + method + source[end:]


def write_temp(target: Path, source: str, has_bom: bool, newline: str):
    payload = source.replace("\n", newline).encode("utf-8")
    if has_bom:
        payload = b"\xef\xbb\xbf" + payload

    handle = tempfile.NamedTemporaryFile(
        mode="wb",
        prefix=target.stem + "_STEP09A_",
        suffix=".py",
        dir=str(target.parent),
        delete=False,
    )
    temp_path = Path(handle.name)

    try:
        handle.write(payload)
    finally:
        handle.close()

    return temp_path


def main() -> int:
    missing = [str(path) for path in TARGETS if not path.is_file()]
    if missing:
        print("ERROR: Chybí cílový soubor:")
        for item in missing:
            print(f"  - {item}")
        return 1

    staged = {}

    try:
        for target in TARGETS:
            source, has_bom, newline = read_source(target)
            patched = patch_source(source)

            if patched == source:
                print(f"ALREADY FIXED: {target}")
                continue

            temp_path = write_temp(target, patched, has_bom, newline)
            py_compile.compile(str(temp_path), doraise=True)
            staged[target] = temp_path

        for target, temp_path in staged.items():
            os.replace(temp_path, target)
            print(f"UPDATED: {target}")

        for target in TARGETS:
            py_compile.compile(str(target), doraise=True)
            print(f"PYTHON SYNTAX OK: {target}")

        if staged:
            print("FINAL STATUS: A17_FINDINGS_PANEL_COLOR_FIXED")
        else:
            print("FINAL STATUS: A17_FINDINGS_PANEL_COLOR_ALREADY_FIXED")

        return 0

    except Exception as exc:
        print(f"ERROR: {exc}")

        for temp_path in staged.values():
            try:
                if temp_path.exists():
                    temp_path.unlink()
            except Exception:
                pass

        return 1


if __name__ == "__main__":
    raise SystemExit(main())
