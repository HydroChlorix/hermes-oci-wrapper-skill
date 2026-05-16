"""Docker integration checks for Hermes Skills Hub install/uninstall.

These tests are opt-in for local development because they require Docker,
network access to the official Hermes image, and network access to the
SKILL.md source URL. The Docker script uses a container-local HERMES_HOME so
host ~/.hermes is never modified.
"""

from __future__ import annotations

import os
import shutil
import subprocess
from pathlib import Path

import pytest


REPO_ROOT = Path(__file__).resolve().parents[2]
SCRIPT = REPO_ROOT / "scripts" / "hermes-skills-install-uninstall-docker.sh"


@pytest.mark.integration
def test_hermes_docker_install_uninstall_oci_wrapper() -> None:
    """Verify oci-wrapper can round-trip through the Hermes Docker runtime."""
    if os.environ.get("RUN_HERMES_DOCKER_INTEGRATION") != "1":
        pytest.skip("set RUN_HERMES_DOCKER_INTEGRATION=1 to run Docker integration")
    if shutil.which("docker") is None:
        pytest.skip("docker is not available")

    assert SCRIPT.exists(), f"missing integration script: {SCRIPT}"

    result = subprocess.run(
        ["bash", str(SCRIPT)],
        cwd=REPO_ROOT,
        env=os.environ.copy(),
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        timeout=600,
        check=False,
    )

    assert result.returncode == 0, result.stdout
    assert "INTEGRATION PASS: oci-wrapper Docker install/uninstall round-trip succeeded" in result.stdout
