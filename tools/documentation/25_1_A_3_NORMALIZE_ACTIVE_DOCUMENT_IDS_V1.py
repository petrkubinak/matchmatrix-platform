# =============================================================================
# MATCHMATRIX
# SOUBOR: 25_1_A_3_NORMALIZE_ACTIVE_DOCUMENT_IDS_V1.py
# SEKCE: 25 – DOCUMENTATION MANAGEMENT SYSTEM
# VERZE: V1
# DATUM: 2026-06-30
#
# CO:
# Bezpečně normalizuje aktivní Document ID a aktivní odkazy ve vybraných
# REVIEW dokumentech MatchMatrix.
#
# K ČEMU:
# - sjednotit ID uvnitř dokumentů s aktuální dokumentační strukturou,
# - připravit dokumenty pro databázový import,
# - zachovat historická označení v MM-DOC-901 až MM-DOC-903,
# - zabránit nekontrolovanému globálnímu nahrazování.
#
# KDE:
# tools/documentation/
# 25_1_A_3_NORMALIZE_ACTIVE_DOCUMENT_IDS_V1.py
#
# JAK:
# Náhled bez změn:
#   py -3.14 tools/documentation/25_1_A_3_NORMALIZE_ACTIVE_DOCUMENT_IDS_V1.py
#
# Skutečné provedení:
#   py -3.14 tools/documentation/25_1_A_3_NORMALIZE_ACTIVE_DOCUMENT_IDS_V1.py
#   --apply
#
# BEZPEČNOST:
# - nepoužívá pevnou cestu k projektu,
# - kořen repozitáře odvozuje z umístění samotného skriptu,
# - standardně běží pouze jako DRY RUN,
# - před zápisem vyžaduje čistý Git repozitář,
# - nejprve ověří všechny soubory a počty výskytů,
# - teprve potom provede zápis,
# - dokumenty MM-DOC-901 až MM-DOC-903 neupravuje,
# - vytváří JSON auditní report.
# =============================================================================

from __future__ import annotations

import argparse
import hashlib
import json
import subprocess
import sys
from dataclasses import asdict, dataclass
from datetime import datetime
from pathlib import Path


EXPECTED_REPLACEMENTS_TOTAL = 20


@dataclass(frozen=True)
class ReplacementRule:
    old_value: str
    new_value: str
    expected_count: int


@dataclass
class PlannedChange:
    relative_path: str
    replacements: dict[str, int]
    replacements_total: int
    sha256_before: str
    sha256_after: str
    changed: bool
    status: str


@dataclass
class FileContent:
    path: Path
    relative_path: str
    original_bytes: bytes
    updated_bytes: bytes
    result: PlannedChange


FILE_RULES: dict[Path, tuple[ReplacementRule, ...]] = {
    Path(
        "docs/01_MASTER/"
        "MM-DOC-100_MATCHMATRIX_MASTER_TECH_REVIEW_v1.md"
    ): (
        ReplacementRule(
            old_value="MM-DOC-001",
            new_value="MM-DOC-100",
            expected_count=2,
        ),
    ),

    Path(
        "docs/02_GOVERNANCE/"
        "MM-DOC-200_MATCHMATRIX_GOVERNANCE_TECH_REVIEW.md"
    ): (
        ReplacementRule(
            old_value="MM-DOC-001",
            new_value="MM-DOC-100",
            expected_count=2,
        ),
        ReplacementRule(
            old_value="MM-DOC-002",
            new_value="MM-DOC-200",
            expected_count=3,
        ),
        ReplacementRule(
            old_value="MM-DOC-003",
            new_value="MM-DOC-300",
            expected_count=3,
        ),
        ReplacementRule(
            old_value="MM-DOC-004",
            new_value="MM-DOC-800",
            expected_count=1,
        ),
        ReplacementRule(
            old_value="MM-DOC-008",
            new_value="MM-DOC-903",
            expected_count=1,
        ),
    ),

    Path(
        "docs/03_ARCHITECTURE/"
        "MM-DOC-300_MATCHMATRIX_ARCHITECTURE_TECH_REVIEW.md"
    ): (
        ReplacementRule(
            old_value="MM-DOC-001",
            new_value="MM-DOC-100",
            expected_count=1,
        ),
        ReplacementRule(
            old_value="MM-DOC-002",
            new_value="MM-DOC-200",
            expected_count=1,
        ),
        ReplacementRule(
            old_value="MM-DOC-003",
            new_value="MM-DOC-300",
            expected_count=3,
        ),
        ReplacementRule(
            old_value="MM-DOC-004",
            new_value="MM-DOC-800",
            expected_count=2,
        ),
    ),

    Path(
        "docs/08_DEVELOPMENT/"
        "MM-DOC-800_MATCHMATRIX_DEVELOPMENT_HANDBOOK_TECH_REVIEW.md"
    ): (
        ReplacementRule(
            old_value="MM-DOC-005",
            new_value="MM-DOC-900",
            expected_count=1,
        ),
    ),
}


FORBIDDEN_DOCUMENTS = {
    "MM-DOC-901_MATCHMATRIX_NAVAZANI_TECH_REVIEW.md",
    "MM-DOC-902_MATCHMATRIX_CHANGELOG_TECH_REVIEW.md",
    "MM-DOC-903_MATCHMATRIX_ARCHITECTURAL_DECISIONS_TECH_REVIEW.md",
}


def find_project_root() -> Path:
    """
    Najde kořen repozitáře MatchMatrix podle umístění tohoto skriptu.

    Kořen musí obsahovat:
    - .git
    - docs
    - db
    """

    script_path = Path(__file__).resolve()

    candidates = (
        script_path.parent,
        *script_path.parents,
    )

    for candidate in candidates:
        if (
            (candidate / ".git").exists()
            and (candidate / "docs").is_dir()
            and (candidate / "db").is_dir()
        ):
            return candidate

    raise RuntimeError(
        "Kořen projektu MatchMatrix nebyl nalezen. "
        "Skript musí být uložen uvnitř Git repozitáře, "
        "který obsahuje .git, docs a db."
    )


def calculate_sha256(content: bytes) -> str:
    return hashlib.sha256(content).hexdigest()


def run_git(
    project_root: Path,
    arguments: list[str],
) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["git", *arguments],
        cwd=project_root,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
        check=False,
    )


def verify_git_repository(project_root: Path) -> None:
    result = run_git(
        project_root,
        ["rev-parse", "--show-toplevel"],
    )

    if result.returncode != 0:
        raise RuntimeError(
            "Projekt není platný Git repozitář:\n"
            f"{result.stderr.strip()}"
        )


def verify_clean_git(project_root: Path) -> None:
    result = run_git(
        project_root,
        ["status", "--porcelain"],
    )

    if result.returncode != 0:
        raise RuntimeError(
            "Nepodařilo se ověřit stav Git repozitáře:\n"
            f"{result.stderr.strip()}"
        )

    changes = [
        line
        for line in result.stdout.splitlines()
        if line.strip()
    ]

    if changes:
        raise RuntimeError(
            "Git repozitář není čistý. "
            "Před automatickou úpravou musí být změny uložené "
            "nebo vrácené.\n\n"
            + "\n".join(changes)
        )


def validate_rule_targets() -> None:
    forbidden_targets = [
        str(path)
        for path in FILE_RULES
        if path.name in FORBIDDEN_DOCUMENTS
    ]

    if forbidden_targets:
        raise RuntimeError(
            "Pravidla obsahují zakázané historické dokumenty:\n"
            + "\n".join(forbidden_targets)
        )


def decode_utf8(
    raw_content: bytes,
) -> tuple[str, bool, str]:
    has_bom = raw_content.startswith(
        b"\xef\xbb\xbf"
    )

    text = raw_content.decode(
        "utf-8-sig"
    )

    newline = (
        "\r\n"
        if "\r\n" in text
        else "\n"
    )

    return text, has_bom, newline


def encode_utf8(
    text: str,
    has_bom: bool,
    newline: str,
) -> bytes:
    normalized = (
        text
        .replace("\r\n", "\n")
        .replace("\r", "\n")
    )

    if newline == "\r\n":
        normalized = normalized.replace(
            "\n",
            "\r\n",
        )

    encoded = normalized.encode(
        "utf-8"
    )

    if has_bom:
        encoded = (
            b"\xef\xbb\xbf"
            + encoded
        )

    return encoded


def prepare_file_change(
    project_root: Path,
    relative_path: Path,
    rules: tuple[ReplacementRule, ...],
) -> FileContent:
    absolute_path = (
        project_root
        / relative_path
    )

    if not absolute_path.is_file():
        raise FileNotFoundError(
            "Cílový dokument nebyl nalezen:\n"
            f"{absolute_path}"
        )

    original_bytes = (
        absolute_path.read_bytes()
    )

    original_text, has_bom, newline = (
        decode_utf8(original_bytes)
    )

    updated_text = original_text
    replacement_results: dict[str, int] = {}
    replacements_total = 0

    for rule in rules:
        actual_count = updated_text.count(
            rule.old_value
        )

        replacement_name = (
            f"{rule.old_value} -> "
            f"{rule.new_value}"
        )

        replacement_results[
            replacement_name
        ] = actual_count

        if actual_count != rule.expected_count:
            raise RuntimeError(
                "Neočekávaný počet výskytů.\n"
                f"Soubor    : {relative_path}\n"
                f"Hodnota   : {rule.old_value}\n"
                f"Očekáváno : {rule.expected_count}\n"
                f"Nalezeno  : {actual_count}\n\n"
                "Nebyla provedena žádná změna."
            )

        updated_text = updated_text.replace(
            rule.old_value,
            rule.new_value,
        )

        replacements_total += actual_count

    updated_bytes = encode_utf8(
        text=updated_text,
        has_bom=has_bom,
        newline=newline,
    )

    changed = (
        updated_bytes != original_bytes
    )

    result = PlannedChange(
        relative_path=str(relative_path),
        replacements=replacement_results,
        replacements_total=replacements_total,
        sha256_before=calculate_sha256(
            original_bytes
        ),
        sha256_after=calculate_sha256(
            updated_bytes
        ),
        changed=changed,
        status=(
            "CHANGE_READY"
            if changed
            else "NO_CHANGE_REQUIRED"
        ),
    )

    return FileContent(
        path=absolute_path,
        relative_path=str(relative_path),
        original_bytes=original_bytes,
        updated_bytes=updated_bytes,
        result=result,
    )


def prepare_all_changes(
    project_root: Path,
) -> list[FileContent]:
    prepared_files: list[FileContent] = []

    for relative_path, rules in FILE_RULES.items():
        prepared_file = prepare_file_change(
            project_root=project_root,
            relative_path=relative_path,
            rules=rules,
        )

        prepared_files.append(
            prepared_file
        )

    replacements_total = sum(
        item.result.replacements_total
        for item in prepared_files
    )

    if (
        replacements_total
        != EXPECTED_REPLACEMENTS_TOTAL
    ):
        raise RuntimeError(
            "Celkový počet náhrad neodpovídá "
            "očekávanému výsledku.\n"
            f"Očekáváno : "
            f"{EXPECTED_REPLACEMENTS_TOTAL}\n"
            f"Nalezeno  : "
            f"{replacements_total}\n\n"
            "Nebyla provedena žádná změna."
        )

    return prepared_files


def apply_changes(
    prepared_files: list[FileContent],
) -> None:
    for prepared_file in prepared_files:
        if (
            prepared_file.updated_bytes
            == prepared_file.original_bytes
        ):
            continue

        prepared_file.path.write_bytes(
            prepared_file.updated_bytes
        )

        prepared_file.result.status = "UPDATED"


def verify_written_files(
    prepared_files: list[FileContent],
) -> None:
    for prepared_file in prepared_files:
        actual_bytes = (
            prepared_file.path.read_bytes()
        )

        actual_hash = calculate_sha256(
            actual_bytes
        )

        if (
            actual_hash
            != prepared_file.result.sha256_after
        ):
            raise RuntimeError(
                "Kontrola zapsaného souboru selhala:\n"
                f"{prepared_file.path}\n"
                f"Očekávaný hash: "
                f"{prepared_file.result.sha256_after}\n"
                f"Skutečný hash : "
                f"{actual_hash}"
            )


def create_report(
    project_root: Path,
    mode: str,
    prepared_files: list[FileContent],
) -> Path:
    report_directory = (
        project_root
        / "reports"
        / "documentation"
    )

    report_directory.mkdir(
        parents=True,
        exist_ok=True,
    )

    timestamp = datetime.now().strftime(
        "%Y%m%d_%H%M%S"
    )

    report_path = (
        report_directory
        / (
            "document_id_normalization_"
            f"{timestamp}.json"
        )
    )

    payload = {
        "generated_at": (
            datetime.now()
            .astimezone()
            .isoformat(timespec="seconds")
        ),
        "project_root": str(
            project_root
        ),
        "mode": mode,
        "files_processed": len(
            prepared_files
        ),
        "replacements_total": sum(
            item.result.replacements_total
            for item in prepared_files
        ),
        "results": [
            asdict(item.result)
            for item in prepared_files
        ],
    }

    report_path.write_text(
        json.dumps(
            payload,
            ensure_ascii=False,
            indent=2,
        ),
        encoding="utf-8",
    )

    return report_path


def print_summary(
    project_root: Path,
    mode: str,
    prepared_files: list[FileContent],
    report_path: Path,
) -> None:
    print()
    print("=" * 79)
    print(
        "MATCHMATRIX DOCUMENT ID NORMALIZATION"
    )
    print("=" * 79)
    print(
        f"PROJECT_ROOT       : "
        f"{project_root}"
    )
    print(
        f"MODE               : "
        f"{mode}"
    )
    print(
        f"FILES PROCESSED    : "
        f"{len(prepared_files)}"
    )
    print(
        "REPLACEMENTS TOTAL: "
        f"{sum(
            item.result.replacements_total
            for item in prepared_files
        )}"
    )
    print()

    for item in prepared_files:
        result = item.result

        print(result.relative_path)
        print(
            f"  status       : "
            f"{result.status}"
        )
        print(
            f"  replacements : "
            f"{result.replacements_total}"
        )

        for replacement, count in (
            result.replacements.items()
        ):
            print(
                f"    {replacement}: "
                f"{count}"
            )

        print(
            f"  sha256 before: "
            f"{result.sha256_before}"
        )
        print(
            f"  sha256 after : "
            f"{result.sha256_after}"
        )
        print()

    print(
        f"REPORT             : "
        f"{report_path}"
    )

    if mode == "APPLY":
        print(
            "FINAL STATUS       : "
            "DOCUMENT_IDS_NORMALIZED"
        )
    else:
        print(
            "FINAL STATUS       : "
            "DRY_RUN_READY_FOR_APPLY"
        )

    print("=" * 79)


def parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Bezpečná normalizace aktivních "
            "Document ID projektu MatchMatrix."
        )
    )

    parser.add_argument(
        "--apply",
        action="store_true",
        help=(
            "Provede skutečný zápis. "
            "Bez parametru běží pouze DRY RUN."
        ),
    )

    return parser.parse_args()


def main() -> int:
    try:
        if hasattr(
            sys.stdout,
            "reconfigure",
        ):
            sys.stdout.reconfigure(
                encoding="utf-8"
            )

        arguments = parse_arguments()
        project_root = find_project_root()

        print(
            f"PROJECT_ROOT: "
            f"{project_root}"
        )

        verify_git_repository(
            project_root
        )

        validate_rule_targets()

        if arguments.apply:
            verify_clean_git(
                project_root
            )

        prepared_files = (
            prepare_all_changes(
                project_root
            )
        )

        mode = (
            "APPLY"
            if arguments.apply
            else "DRY_RUN"
        )

        if arguments.apply:
            apply_changes(
                prepared_files
            )

            verify_written_files(
                prepared_files
            )

        report_path = create_report(
            project_root=project_root,
            mode=mode,
            prepared_files=prepared_files,
        )

        print_summary(
            project_root=project_root,
            mode=mode,
            prepared_files=prepared_files,
            report_path=report_path,
        )

        return 0

    except Exception as exc:
        print(
            f"FATAL: "
            f"{type(exc).__name__}: "
            f"{exc}",
            file=sys.stderr,
        )

        return 1


if __name__ == "__main__":
    raise SystemExit(
        main()
    )