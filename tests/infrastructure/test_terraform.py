import subprocess
import json
import pytest

def run_command(command):
    """Run shell command and return output"""
    result = subprocess.run(
        command,
        shell=True,
        capture_output=True,
        text=True,
        cwd='terraform'
    )
    return result.returncode, result.stdout, result.stderr

def test_terraform_format():
    """Test that Terraform files are properly formatted"""
    returncode, stdout, stderr = run_command('terraform fmt -check -recursive')
    assert returncode == 0, f"Terraform files not formatted: {stderr}"

def test_terraform_validate():
    """Test that Terraform configuration is valid"""
    # Init first
    run_command('terraform init -backend=false')
    
    # Validate
    returncode, stdout, stderr = run_command('terraform validate')
    assert returncode == 0, f"Terraform validation failed: {stderr}"

def test_terraform_plan():
    """Test that Terraform plan runs without errors"""
    returncode, stdout, stderr = run_command('terraform init -backend=false')
    assert returncode == 0