"""Machine-runtime integration checks for Hermes Skills Hub install/uninstall.

These tests are opt-in because they require a host Hermes CLI and network
access to the SKILL.md source URL. The shell script sets HERMES_HOME to a
fresh temporary directory so the real user ~/.hermes is never modified.
"""

from __future__ import annotations

import os
import shutil
import subprocess
from pathlib import Path

import pytest


REPO_ROOT = Path(__file__).resolve().parents[2]
SCRIPT = REPO_ROOT / "scripts" / "hermes-skills-install-uninstall-machine.sh"


@pytest.mark.integration
def test_hermes_machine_install_uninstall_oci_wrapper() -> None:
    """Verify oci-wrapper can round-trip through the host Hermes runtime."""
    if os.environ.get("RUN_HERMES_MACHINE_INTEGRATION") != "1":
        pytest.skip("set RUN_HERMES_MACHINE_INTEGRATION=1 to run machine integration")
    if shutil.which(os.environ.get("HERMES_BIN", "hermes")) is None:
        pytest.skip("hermes is not available on PATH")

    assert SCRIPT.exists(), f"missing integration script: {SCRIPT}"

    result = subprocess.run(
        ["bash", str(SCRIPT)],
        cwd=REPO_ROOT,
        env=os.environ.copy(),
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        timeout=300,
        check=False,
    )

    assert result.returncode == 0, result.stdout
    assert "INTEGRATION PASS: oci-wrapper machine install/uninstall round-trip succeeded" in result.stdout
