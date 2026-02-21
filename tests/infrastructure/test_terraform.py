import subprocess
import json
import pytest

def run_command(command):
    result = subprocess.run(
        command,
        shell=True,
        capture_output=True,
        text=True,
        cwd='terraform'
    )
    return result.returncode, result.stdout, result.stderr

def test_terraform_format():
    returncode, stdout, stderr = run_command('terraform fmt -check -recursive')

def test_terraform_files_exist():
    """Test that required Terraform files exist"""
    import os
    assert os.path.exists('terraform/main.tf')
    assert os.path.exists('terraform/variables.tf')
    assert os.path.exists('terraform/outputs.tf')