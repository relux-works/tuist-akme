#!/usr/bin/env python3

"""
check_swift_docs.py

This script enforces inline documentation coverage for the project's Tuist DSL layer (manifests
and plugins), not for arbitrary app/framework sources.

By default it scans:
- TuistPlugins/ProjectInfraPlugin/ProjectDescriptionHelpers
- Tuist/ProjectDescriptionHelpers

The goal is to keep the public/internal DSL surface self-documenting and easy to maintain as the
project scales.
"""

from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parent.parent


DEFAULT_PATHS: list[Path] = [
    REPO_ROOT / "TuistPlugins" / "ProjectInfraPlugin" / "ProjectDescriptionHelpers",
    REPO_ROOT / "Tuist" / "ProjectDescriptionHelpers",
]


DEFAULT_EXCLUDES: set[Path] = {
}


_DECLARATION_RE = re.compile(
    r"^\s*(?:public|internal|fileprivate|private)?\s*"
    r"(?:final\s+)?(?:static\s+|class\s+)?"
    r"(struct|enum|class|protocol|typealias|extension|func|init|subscript|let|var)\b"
)

_TYPE_RE = re.compile(
    r"^\s*(?:public|internal|fileprivate|private)?\s*(?:final\s+)?"
    r"(struct|enum|class|protocol|extension)\b"
)

_FUNC_RE = re.compile(
    r"^\s*(?:public|internal|fileprivate|private)?\s*(?:static\s+|class\s+)?(func|init|subscript)\b"
)

_COMPUTED_PROPERTY_RE = re.compile(
    r"^\s*(?:public|internal|fileprivate|private)?\s*(?:static\s+|class\s+)?(let|var)\b.*\{\s*$"
)

_CLOSURE_START_RE = re.compile(r"=.*\{\s*$")

_DOC_RE = re.compile(r"^\s*(///|/\*\*)")

_ATTRIBUTE_RE = re.compile(r"^\s*@\w+")


@dataclass(frozen=True)
class Finding:
    file: Path
    line: int
    declaration: str


def _count_braces(line: str) -> tuple[int, int]:
    # Note: This is intentionally simple (doesn't attempt to ignore strings/comments).
    return line.count("{"), line.count("}")


def _is_doc_line(line: str) -> bool:
    return _DOC_RE.match(line) is not None


def _is_attribute_line(line: str) -> bool:
    return _ATTRIBUTE_RE.match(line) is not None


def _prev_doc_line(lines: list[str], index: int) -> str | None:
    j = index - 1
    while j >= 0:
        previous = lines[j]
        if not previous.strip():
            j -= 1
            continue
        if _is_attribute_line(previous):
            j -= 1
            continue

        # Support multi-line attributes (for example `@available(...)` blocks) where the lines
        # between the attribute and the declaration don't start with `@`.
        lookback_limit = 20
        k = j
        while k >= 0 and (j - k) <= lookback_limit:
            candidate = lines[k].strip()
            if not candidate:
                break
            if _is_doc_line(lines[k]):
                break
            if candidate.startswith("@"):
                j = k - 1
                previous = ""
                break
            k -= 1
        if previous == "":
            continue
        return previous
    return None


def _is_declaration_line(line: str) -> bool:
    stripped = line.strip()
    if not stripped:
        return False
    if stripped.startswith("import "):
        return False
    if stripped.startswith("//"):
        return False
    if stripped.startswith("case "):
        return False
    return _DECLARATION_RE.match(line) is not None


def _scan_file(file_path: Path) -> list[Finding]:
    lines = file_path.read_text(encoding="utf-8").splitlines()
    findings: list[Finding] = []

    brace_depth = 0
    code_stack: list[int] = []
    pending_context: str | None = None  # "type" | "code"
    pending_depth: int | None = None

    for i, line in enumerate(lines):
        stripped = line.strip()

        # Check docs for declarations that are not inside a code block (function/closure body).
        if not code_stack and _is_declaration_line(line):
            previous = _prev_doc_line(lines, i)
            if previous is None or not _is_doc_line(previous):
                findings.append(Finding(file=file_path, line=i + 1, declaration=line.rstrip()))

        # Skip doc/attribute lines for context detection.
        #
        # Note: We don't try to track nested code blocks while already inside a code block because
        # we don't report missing docs there.
        if not code_stack and stripped and not stripped.startswith(("///", "/**")) and not _is_attribute_line(line):
            if _TYPE_RE.match(line):
                pending_context = "type"
                pending_depth = brace_depth
            elif _FUNC_RE.match(line):
                pending_context = "code"
                pending_depth = brace_depth
            elif _COMPUTED_PROPERTY_RE.match(line):
                pending_context = "code"
                pending_depth = brace_depth
            elif _CLOSURE_START_RE.search(line) and stripped.endswith("{"):
                pending_context = "code"
                pending_depth = brace_depth

        opens, closes = _count_braces(line)

        # If a pending context exists and we see an opening brace at the same depth, assume the
        # first `{` starts that context.
        if pending_context and pending_depth is not None and opens > 0 and brace_depth == pending_depth:
            if pending_context == "code":
                code_stack.append(brace_depth + 1)
            pending_context = None
            pending_depth = None

        brace_depth += opens - closes
        if brace_depth < 0:
            brace_depth = 0

        while code_stack and brace_depth < code_stack[-1]:
            code_stack.pop()

    return findings


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Check for missing Swift doc comments (///) in Tuist DSL helpers."
    )
    parser.add_argument(
        "paths",
        nargs="*",
        help="Paths to scan (defaults to Tuist DSL helper directories).",
    )
    parser.add_argument(
        "--exclude",
        action="append",
        default=[],
        help="Paths to exclude (can be passed multiple times).",
    )
    args = parser.parse_args()

    paths: list[Path] = [Path(p).resolve() for p in args.paths] if args.paths else DEFAULT_PATHS
    excludes: set[Path] = set(DEFAULT_EXCLUDES)
    excludes |= {Path(p).resolve() for p in args.exclude}

    swift_files: list[Path] = []
    for path in paths:
        if path.is_file() and path.suffix == ".swift":
            swift_files.append(path)
        elif path.is_dir():
            swift_files.extend(sorted(path.rglob("*.swift")))

    swift_files = [p for p in swift_files if p not in excludes]

    findings: list[Finding] = []
    for file_path in swift_files:
        findings.extend(_scan_file(file_path))

    if not findings:
        print("✅ docs: all checked Swift declarations are documented.")
        return 0

    print("🛑 docs: missing documentation comments (expected ///):")
    for finding in findings:
        rel = finding.file.relative_to(REPO_ROOT)
        print(f"- {rel}:{finding.line}: {finding.declaration.strip()}")

    print(f"\nTotal missing docs: {len(findings)}")
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
