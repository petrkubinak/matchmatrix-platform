#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
MatchMatrix - Windows file audit

Projde zadané složky projektu, vytvoří snapshot souborů a vygeneruje reporty:
- CSV kompletní seznam souborů
- CSV změny oproti poslednímu snapshotu
- Markdown souhrn
- JSON snapshot pro další porovnání

Zaměření:
- workers
- ingest
- ingest/API-Football
- Scripts
- Dump

Autor: OpenAI / ChatGPT
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import os
from dataclasses import dataclass, asdict
from datetime import datetime
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Tuple


DEFAULT_TARGETS = {
    "workers": r"C:\MatchMatrix-platform\workers",
    "ingest": r"C:\MatchMatrix-platform\ingest",
    "api_football": r"C:\MatchMatrix-platform\ingest\API-Football",
    "scripts": r"C:\MatchMatrix-platform\MatchMatrix-platform\Scripts",
    "dump": r"C:\MatchMatrix-platform\MatchMatrix-platform\Dump",
}

ALLOWED_EXTENSIONS = {
    ".py", ".ps1", ".psm1", ".sql", ".md", ".txt", ".json", ".yaml", ".yml",
    ".bat", ".cmd", ".psd1", ".csv", ".log", ".ini", ".env", ".ipynb"
}

IGNORE_DIR_NAMES = {
    "__pycache__", ".git", ".venv", "venv", ".idea", ".vscode", "node_modules"
}


@dataclass
class FileRecord:
    target: str
    root_path: str
    full_path: str
    relative_path: str
    extension: str
    size_bytes: int
    created_at: str
    modified_at: str
    file_hash: Optional[str]


@dataclass
class ChangeRecord:
    change_type: str
    target: str
    relative_path: str
    full_path: str
    old_modified_at: Optional[str]
    new_modified_at: Optional[str]
    old_size_bytes: Optional[int]
    new_size_bytes: Optional[int]
    old_hash: Optional[str]
    new_hash: Optional[str]


@dataclass
class TargetSummary:
    target: str
    root_path: str
    files_count: int
    total_size_bytes: int
    newest_modified_at: Optional[str]
    by_extension: Dict[str, int]


def utc_now_stamp() -> str:
    return datetime.now().strftime("%Y%m%d_%H%M%S")


def iso_ts(ts: float) -> str:
    return datetime.fromtimestamp(ts).strftime("%Y-%m-%d %H:%M:%S")


def sha1_of_file(path: Path, chunk_size: int = 1024 * 1024) -> str:
    h = hashlib.sha1()
    with path.open("rb") as f:
        while True:
            chunk = f.read(chunk_size)
            if not chunk:
                break
            h.update(chunk)
    return h.hexdigest()


def should_skip_dir(dirname: str) -> bool:
    return dirname.lower() in {d.lower() for d in IGNORE_DIR_NAMES}


def scan_target(target_name: str, root_path: Path, use_hash: bool, only_known_extensions: bool) -> List[FileRecord]:
    records: List[FileRecord] = []
    if not root_path.exists():
        return records

    for current_root, dirs, files in os.walk(root_path):
        dirs[:] = [d for d in dirs if not should_skip_dir(d)]
        current_root_path = Path(current_root)

        for filename in files:
            full_path = current_root_path / filename
            ext = full_path.suffix.lower()
            if only_known_extensions and ext not in ALLOWED_EXTENSIONS:
                continue

            try:
                stat = full_path.stat()
                rel = full_path.relative_to(root_path).as_posix()
                file_hash = sha1_of_file(full_path) if use_hash else None
                records.append(
                    FileRecord(
                        target=target_name,
                        root_path=str(root_path),
                        full_path=str(full_path),
                        relative_path=rel,
                        extension=ext,
                        size_bytes=stat.st_size,
                        created_at=iso_ts(stat.st_ctime),
                        modified_at=iso_ts(stat.st_mtime),
                        file_hash=file_hash,
                    )
                )
            except (OSError, PermissionError) as exc:
                print(f"WARN: Nelze přečíst {full_path}: {exc}")

    return sorted(records, key=lambda r: (r.target, r.relative_path.lower()))


def write_csv(path: Path, rows: Iterable[dict], fieldnames: List[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8-sig") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames, delimiter=";")
        writer.writeheader()
        for row in rows:
            writer.writerow(row)


def write_json(path: Path, payload: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as f:
        json.dump(payload, f, ensure_ascii=False, indent=2)


def load_snapshot(path: Path) -> Optional[dict]:
    if not path.exists():
        return None
    with path.open("r", encoding="utf-8") as f:
        return json.load(f)


def build_summaries(records: List[FileRecord]) -> List[TargetSummary]:
    grouped: Dict[Tuple[str, str], List[FileRecord]] = {}
    for r in records:
        grouped.setdefault((r.target, r.root_path), []).append(r)

    summaries: List[TargetSummary] = []
    for (target, root_path), items in grouped.items():
        by_ext: Dict[str, int] = {}
        newest: Optional[str] = None
        total = 0
        for item in items:
            by_ext[item.extension or "[no_ext]"] = by_ext.get(item.extension or "[no_ext]", 0) + 1
            total += item.size_bytes
            if newest is None or item.modified_at > newest:
                newest = item.modified_at
        summaries.append(
            TargetSummary(
                target=target,
                root_path=root_path,
                files_count=len(items),
                total_size_bytes=total,
                newest_modified_at=newest,
                by_extension=dict(sorted(by_ext.items(), key=lambda x: (-x[1], x[0]))),
            )
        )
    return sorted(summaries, key=lambda s: s.target)


def index_snapshot(snapshot: dict) -> Dict[Tuple[str, str], dict]:
    out: Dict[Tuple[str, str], dict] = {}
    for rec in snapshot.get("records", []):
        out[(rec["target"], rec["relative_path"])] = rec
    return out


def compare_snapshots(old_snapshot: Optional[dict], new_records: List[FileRecord]) -> List[ChangeRecord]:
    if not old_snapshot:
        return [
            ChangeRecord(
                change_type="NEW",
                target=r.target,
                relative_path=r.relative_path,
                full_path=r.full_path,
                old_modified_at=None,
                new_modified_at=r.modified_at,
                old_size_bytes=None,
                new_size_bytes=r.size_bytes,
                old_hash=None,
                new_hash=r.file_hash,
            )
            for r in new_records
        ]

    old_index = index_snapshot(old_snapshot)
    new_index = {(r.target, r.relative_path): r for r in new_records}
    changes: List[ChangeRecord] = []

    for key, new_rec in new_index.items():
        old_rec = old_index.get(key)
        if old_rec is None:
            changes.append(ChangeRecord(
                change_type="NEW",
                target=new_rec.target,
                relative_path=new_rec.relative_path,
                full_path=new_rec.full_path,
                old_modified_at=None,
                new_modified_at=new_rec.modified_at,
                old_size_bytes=None,
                new_size_bytes=new_rec.size_bytes,
                old_hash=None,
                new_hash=new_rec.file_hash,
            ))
            continue

        changed = (
            old_rec.get("size_bytes") != new_rec.size_bytes
            or old_rec.get("modified_at") != new_rec.modified_at
            or old_rec.get("file_hash") != new_rec.file_hash
        )
        if changed:
            changes.append(ChangeRecord(
                change_type="MODIFIED",
                target=new_rec.target,
                relative_path=new_rec.relative_path,
                full_path=new_rec.full_path,
                old_modified_at=old_rec.get("modified_at"),
                new_modified_at=new_rec.modified_at,
                old_size_bytes=old_rec.get("size_bytes"),
                new_size_bytes=new_rec.size_bytes,
                old_hash=old_rec.get("file_hash"),
                new_hash=new_rec.file_hash,
            ))

    for key, old_rec in old_index.items():
        if key not in new_index:
            changes.append(ChangeRecord(
                change_type="DELETED",
                target=old_rec["target"],
                relative_path=old_rec["relative_path"],
                full_path=old_rec["full_path"],
                old_modified_at=old_rec.get("modified_at"),
                new_modified_at=None,
                old_size_bytes=old_rec.get("size_bytes"),
                new_size_bytes=None,
                old_hash=old_rec.get("file_hash"),
                new_hash=None,
            ))

    return sorted(changes, key=lambda c: (c.change_type, c.target, c.relative_path.lower()))


def latest_snapshot_file(snapshot_dir: Path) -> Optional[Path]:
    files = sorted(snapshot_dir.glob("snapshot_*.json"))
    return files[-1] if files else None


def format_bytes(n: int) -> str:
    units = ["B", "KB", "MB", "GB", "TB"]
    size = float(n)
    for unit in units:
        if size < 1024 or unit == units[-1]:
            return f"{size:.2f} {unit}"
        size /= 1024
    return f"{n} B"


def build_markdown_report(
    report_path: Path,
    run_ts: str,
    summaries: List[TargetSummary],
    changes: List[ChangeRecord],
    compared_to: Optional[str],
) -> None:
    lines: List[str] = []
    lines.append("# MatchMatrix – audit souborů")
    lines.append("")
    lines.append(f"- Čas běhu: **{run_ts}**")
    lines.append(f"- Porovnání s předchozím snapshotem: **{compared_to or 'ne'}**")
    lines.append("")
    lines.append("## Souhrn složek")
    lines.append("")
    lines.append("| Cíl | Složka | Počet souborů | Velikost | Nejnovější změna |")
    lines.append("|---|---|---:|---:|---|")
    for s in summaries:
        lines.append(
            f"| {s.target} | `{s.root_path}` | {s.files_count} | {format_bytes(s.total_size_bytes)} | {s.newest_modified_at or ''} |"
        )

    lines.append("")
    lines.append("## Změny oproti minulému běhu")
    lines.append("")
    if not changes:
        lines.append("Žádné změny.")
    else:
        new_cnt = sum(1 for c in changes if c.change_type == "NEW")
        mod_cnt = sum(1 for c in changes if c.change_type == "MODIFIED")
        del_cnt = sum(1 for c in changes if c.change_type == "DELETED")
        lines.append(f"- Nové: **{new_cnt}**")
        lines.append(f"- Upravené: **{mod_cnt}**")
        lines.append(f"- Smazané: **{del_cnt}**")
        lines.append("")
        lines.append("| Typ | Cíl | Relativní cesta | Stará změna | Nová změna |")
        lines.append("|---|---|---|---|---|")
        for c in changes:
            lines.append(
                f"| {c.change_type} | {c.target} | `{c.relative_path}` | {c.old_modified_at or ''} | {c.new_modified_at or ''} |"
            )

    lines.append("")
    lines.append("## Struktura podle přípon")
    lines.append("")
    for s in summaries:
        lines.append(f"### {s.target}")
        lines.append("")
        for ext, count in s.by_extension.items():
            lines.append(f"- `{ext}`: {count}")
        lines.append("")

    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text("\n".join(lines), encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description="MatchMatrix audit souborů")
    parser.add_argument("--output-dir", default=r"C:\MatchMatrix-platform\reports\file_audit", help="Výstupní složka reportů")
    parser.add_argument("--no-hash", action="store_true", help="Nevypočítávat SHA1 hash souborů")
    parser.add_argument("--all-files", action="store_true", help="Neomezovat audit jen na známé přípony")
    parser.add_argument("--compare", default="latest", help="Cesta ke snapshot JSON nebo 'latest'")
    args = parser.parse_args()

    output_dir = Path(args.output_dir)
    snapshot_dir = output_dir / "snapshots"
    csv_dir = output_dir / "csv"
    md_dir = output_dir / "md"

    run_ts = utc_now_stamp()
    use_hash = not args.no_hash
    only_known_extensions = not args.all_files

    all_records: List[FileRecord] = []
    missing_targets: List[Tuple[str, str]] = []

    for target_name, raw_path in DEFAULT_TARGETS.items():
        root = Path(raw_path)
        if not root.exists():
            missing_targets.append((target_name, raw_path))
            continue
        all_records.extend(scan_target(target_name, root, use_hash=use_hash, only_known_extensions=only_known_extensions))

    summaries = build_summaries(all_records)

    previous_snapshot: Optional[dict] = None
    compared_to: Optional[str] = None
    if args.compare:
        if args.compare == "latest":
            prev = latest_snapshot_file(snapshot_dir)
            if prev and prev.exists():
                previous_snapshot = load_snapshot(prev)
                compared_to = str(prev)
        else:
            prev = Path(args.compare)
            if prev.exists():
                previous_snapshot = load_snapshot(prev)
                compared_to = str(prev)

    changes = compare_snapshots(previous_snapshot, all_records)

    snapshot_payload = {
        "run_ts": run_ts,
        "targets": DEFAULT_TARGETS,
        "missing_targets": [{"target": t, "path": p} for t, p in missing_targets],
        "records": [asdict(r) for r in all_records],
        "summaries": [asdict(s) for s in summaries],
    }

    snapshot_file = snapshot_dir / f"snapshot_{run_ts}.json"
    files_csv = csv_dir / f"files_{run_ts}.csv"
    changes_csv = csv_dir / f"changes_{run_ts}.csv"
    report_md = md_dir / f"report_{run_ts}.md"
    latest_json = output_dir / "latest_snapshot.json"
    latest_report = output_dir / "latest_report.md"
    latest_files_csv = output_dir / "latest_files.csv"
    latest_changes_csv = output_dir / "latest_changes.csv"

    write_json(snapshot_file, snapshot_payload)
    write_json(latest_json, snapshot_payload)

    write_csv(
        files_csv,
        [asdict(r) for r in all_records],
        fieldnames=[
            "target", "root_path", "full_path", "relative_path", "extension",
            "size_bytes", "created_at", "modified_at", "file_hash"
        ],
    )
    write_csv(
        latest_files_csv,
        [asdict(r) for r in all_records],
        fieldnames=[
            "target", "root_path", "full_path", "relative_path", "extension",
            "size_bytes", "created_at", "modified_at", "file_hash"
        ],
    )

    write_csv(
        changes_csv,
        [asdict(c) for c in changes],
        fieldnames=[
            "change_type", "target", "relative_path", "full_path",
            "old_modified_at", "new_modified_at",
            "old_size_bytes", "new_size_bytes", "old_hash", "new_hash"
        ],
    )
    write_csv(
        latest_changes_csv,
        [asdict(c) for c in changes],
        fieldnames=[
            "change_type", "target", "relative_path", "full_path",
            "old_modified_at", "new_modified_at",
            "old_size_bytes", "new_size_bytes", "old_hash", "new_hash"
        ],
    )

    build_markdown_report(report_md, run_ts, summaries, changes, compared_to)
    build_markdown_report(latest_report, run_ts, summaries, changes, compared_to)

    print("=" * 80)
    print("MATCHMATRIX FILE AUDIT")
    print("=" * 80)
    print(f"Run timestamp        : {run_ts}")
    print(f"Output directory     : {output_dir}")
    print(f"Compared to          : {compared_to or 'none'}")
    print(f"Hash enabled         : {use_hash}")
    print(f"Known extensions only: {only_known_extensions}")
    print("-" * 80)
    for s in summaries:
        print(f"{s.target:12} files={s.files_count:5d} size={format_bytes(s.total_size_bytes):>10} newest={s.newest_modified_at}")
    if missing_targets:
        print("-" * 80)
        print("Chybějící složky:")
        for t, p in missing_targets:
            print(f"  - {t}: {p}")
    print("-" * 80)
    print(f"Changes detected     : {len(changes)}")
    print(f"Files CSV            : {files_csv}")
    print(f"Changes CSV          : {changes_csv}")
    print(f"Markdown report      : {report_md}")
    print(f"Snapshot JSON        : {snapshot_file}")
    print("Hotovo.")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
