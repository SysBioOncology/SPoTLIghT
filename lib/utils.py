import os
import platform
from importlib.metadata import version
from pathlib import Path


def generate_versions_yml(pkgs, task_id, output_dir=os.getcwd(), nspaces: int = 2):
    indent = " " * int(nspaces)
    python_version = list(f"{indent}python: {platform.python_version()}\n")
    versions = python_version + [f"{indent}{pkg}: {version(pkg)}\n" for pkg in pkgs]

    with open(Path(output_dir, "versions.yml"), "w") as versions_file:
        versions_file.writelines([f"{task_id}:\n"] + versions)
