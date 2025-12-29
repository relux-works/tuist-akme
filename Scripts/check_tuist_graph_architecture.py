#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import subprocess
import sys
import tempfile
import time
from dataclasses import dataclass
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parent.parent


_MODULE_KINDS = {"interface", "impl", "testing", "tests"}
_MODULE_LAYERS = {"core", "compositionRoot", "feature", "shared", "utility", "app"}


@dataclass(frozen=True)
class _TargetKey:
    project_path: str
    target_name: str


@dataclass(frozen=True)
class _ModuleTarget:
    layer: str
    module_name: str
    kind: str
    bundle_id: str


def _safe_print(message: str, *, file=sys.stdout) -> None:
    try:
        print(message, file=file, flush=True)
    except BrokenPipeError:
        raise SystemExit(0)


def _run_tuist_graph_json(output_dir: Path) -> Path:
    cmd = [
        "tuist",
        "graph",
        "-f",
        "json",
        "--no-open",
        "-o",
        str(output_dir),
    ]
    subprocess.run(cmd, cwd=str(REPO_ROOT), check=True)
    graph_path = output_dir / "graph.json"
    if not graph_path.exists():
        raise RuntimeError(f"Expected graph output at {graph_path}")
    return graph_path


def _parse_module_target(bundle_id: str) -> _ModuleTarget | None:
    parts = [p for p in bundle_id.split(".") if p]
    if len(parts) < 2:
        return None

    kind = parts[-1]
    if kind not in _MODULE_KINDS:
        return None

    layer_index: int | None = None
    for index, component in enumerate(parts[:-1]):
        if component in _MODULE_LAYERS:
            layer_index = index

    if layer_index is None:
        return None

    module_index = layer_index + 1
    if module_index >= len(parts) - 1:
        return None

    layer = parts[layer_index]
    module_name = parts[module_index]
    return _ModuleTarget(layer=layer, module_name=module_name, kind=kind, bundle_id=bundle_id)


def _iter_project_objects(graph: dict) -> list[dict]:
    projects: list[dict] = []
    for item in graph.get("projects", []):
        if isinstance(item, dict) and "path" in item and "targets" in item:
            projects.append(item)
    return projects


def _load_graph(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def _build_target_index(graph: dict) -> dict[_TargetKey, _ModuleTarget | None]:
    index: dict[_TargetKey, _ModuleTarget | None] = {}
    for project in _iter_project_objects(graph):
        project_path = str(project.get("path"))
        targets = project.get("targets", {})
        if not isinstance(targets, dict):
            continue
        for target_name, target in targets.items():
            if not isinstance(target, dict):
                continue
            bundle_id = target.get("bundleId")
            module_target = (
                _parse_module_target(bundle_id) if isinstance(bundle_id, str) else None
            )
            index[_TargetKey(project_path=project_path, target_name=target_name)] = module_target
    return index


def _iter_edges(graph: dict) -> list[tuple[_TargetKey, _TargetKey]]:
    edges: list[tuple[_TargetKey, _TargetKey]] = []
    for project in _iter_project_objects(graph):
        project_path = str(project.get("path"))
        targets = project.get("targets", {})
        if not isinstance(targets, dict):
            continue

        for source_target_name, target in targets.items():
            if not isinstance(target, dict):
                continue

            source_key = _TargetKey(
                project_path=project_path, target_name=source_target_name
            )
            dependencies = target.get("dependencies", [])
            if not isinstance(dependencies, list):
                continue

            for dep in dependencies:
                if not isinstance(dep, dict):
                    continue

                if "project" in dep and isinstance(dep["project"], dict):
                    destination_project_path = str(dep["project"].get("path", ""))
                    destination_target = dep["project"].get("target")
                    if not destination_project_path or not isinstance(
                        destination_target, str
                    ):
                        continue
                    dest_key = _TargetKey(
                        project_path=destination_project_path,
                        target_name=destination_target,
                    )
                    edges.append((source_key, dest_key))
                    continue

                if "target" in dep and isinstance(dep["target"], dict):
                    destination_target = dep["target"].get("name")
                    if not isinstance(destination_target, str):
                        continue
                    dest_key = _TargetKey(
                        project_path=project_path, target_name=destination_target
                    )
                    edges.append((source_key, dest_key))
                    continue

    return edges


def _check_no_illegal_impl_to_impl_edges(
    target_index: dict[_TargetKey, _ModuleTarget | None],
    edges: list[tuple[_TargetKey, _TargetKey]],
) -> list[str]:
    violations: list[str] = []

    for source, dest in edges:
        source_module = target_index.get(source)
        dest_module = target_index.get(dest)

        if source_module is None or dest_module is None:
            continue

        if source_module.kind != "impl" or dest_module.kind != "impl":
            continue

        if source.project_path == dest.project_path and source.target_name == dest.target_name:
            continue

        if source_module.layer == "compositionRoot":
            continue

        violations.append(
            "🛑 ARCHITECTURE VIOLATION 🛑\n"
            "---------------------------------------------------\n"
            f"Rule: Non-composition-root Impl targets must not link other Impl targets.\n"
            f"From: {source.project_path} :: {source.target_name} ({source_module.bundle_id})\n"
            f"To:   {dest.project_path} :: {dest.target_name} ({dest_module.bundle_id})\n"
            "Fix:\n"
            "- Depend on the other module's Interface target instead, or\n"
            "- Move wiring into a CompositionRoot.\n"
            "---------------------------------------------------"
        )

    return violations


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Validate architectural dependency rules using `tuist graph -f json`."
    )
    parser.add_argument(
        "--graph",
        type=Path,
        help="Path to an existing graph.json (skips running `tuist graph`).",
    )
    args = parser.parse_args()

    start = time.perf_counter()

    if args.graph:
        graph_path = args.graph
    else:
        with tempfile.TemporaryDirectory(prefix="tuist-graph.") as tmp_dir:
            graph_path = _run_tuist_graph_json(Path(tmp_dir))
            graph = _load_graph(graph_path)
    if args.graph:
        graph = _load_graph(graph_path)

    target_index = _build_target_index(graph)
    edges = _iter_edges(graph)
    violations = _check_no_illegal_impl_to_impl_edges(target_index, edges)

    duration_ms = int((time.perf_counter() - start) * 1000)

    if violations:
        _safe_print("\n\n".join(violations), file=sys.stderr)
        _safe_print(f"❌ graph check failed ({len(violations)} violations, {duration_ms}ms).", file=sys.stderr)
        return 1

    _safe_print(f"✅ graph check passed ({len(edges)} edges, {duration_ms}ms).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

