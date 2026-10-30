#!/usr/bin/env python3
"""
Code signing helper script for scad-format.

This script handles code signing via SignPath. If signing is not available
(e.g., certificate pending, missing credentials), it will warn but not fail.

Usage:
    python scripts/sign_artifact.py <artifact_path> [--fail-on-error]

Environment variables:
    SIGNPATH_API_TOKEN      - SignPath API token
    SIGNPATH_ORGANIZATION   - SignPath organization ID
    SIGNPATH_PROJECT        - SignPath project slug (default: scad-format)
    SIGNPATH_POLICY         - Signing policy slug (default: release-signing)
"""

import argparse
import os
import sys
import subprocess
import time


def get_env_or_warn(name: str, default: str = None) -> str:
  """Get environment variable or return default with warning."""
  value = os.environ.get(name, default)
  if value is None:
    print(f"WARNING: Environment variable {name} not set", file=sys.stderr)
  return value


def check_signpath_cli() -> bool:
  """Check if SignPath CLI is available."""
  try:
    result = subprocess.run(["SignPath.exe", "--version"],
                            capture_output=True,
                            text=True,
                            timeout=10)
    return result.returncode == 0
  except (subprocess.TimeoutExpired, FileNotFoundError):
    return False


def sign_artifact(artifact_path: str,
                  organization_id: str,
                  project_slug: str,
                  signing_policy_slug: str,
                  api_token: str,
                  artifact_config_slug: str = None,
                  wait_for_completion: bool = True,
                  timeout_minutes: int = 10) -> bool:
  """
    Submit an artifact for signing via SignPath.
    
    Returns True if signing succeeded, False otherwise.
    """
  if not os.path.exists(artifact_path):
    print(f"ERROR: Artifact not found: {artifact_path}", file=sys.stderr)
    return False

  cmd = [
    "SignPath.exe",
    "submit",
    "--organization-id",
    organization_id,
    "--project-slug",
    project_slug,
    "--signing-policy-slug",
    signing_policy_slug,
    "--artifact-configuration-slug",
    artifact_config_slug or "default",
    "--input-artifact-path",
    artifact_path,
    "--api-token",
    api_token,
  ]

  if wait_for_completion:
    cmd.extend([
      "--wait-for-completion",
      "--wait-for-completion-timeout-in-seconds",
      str(timeout_minutes * 60),
      "--output-artifact-path",
      artifact_path,  # Overwrite with signed version
    ])

  print(f"Submitting {artifact_path} for signing...")

  try:
    result = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout_minutes * 60 + 60)

    if result.returncode == 0:
      print(f"SUCCESS: {artifact_path} signed successfully")
      return True
    else:
      print(f"WARNING: Signing failed with code {result.returncode}", file=sys.stderr)
      if result.stderr:
        print(f"  stderr: {result.stderr}", file=sys.stderr)
      if result.stdout:
        print(f"  stdout: {result.stdout}", file=sys.stderr)
      return False

  except subprocess.TimeoutExpired:
    print(f"WARNING: Signing timed out after {timeout_minutes} minutes", file=sys.stderr)
    return False
  except Exception as e:
    print(f"WARNING: Signing failed with exception: {e}", file=sys.stderr)
    return False


def main():
  parser = argparse.ArgumentParser(description="Sign artifacts using SignPath",
                                   formatter_class=argparse.RawDescriptionHelpFormatter,
                                   epilog=__doc__)
  parser.add_argument("artifact", help="Path to artifact to sign")
  parser.add_argument("--fail-on-error",
                      action="store_true",
                      help="Exit with error code if signing fails (default: warn only)")
  parser.add_argument("--artifact-config", default=None, help="Artifact configuration slug")
  parser.add_argument("--timeout", type=int, default=10, help="Timeout in minutes (default: 10)")

  args = parser.parse_args()

  # Get configuration from environment
  api_token = get_env_or_warn("SIGNPATH_API_TOKEN")
  organization_id = get_env_or_warn("SIGNPATH_ORGANIZATION")
  project_slug = get_env_or_warn("SIGNPATH_PROJECT", "scad-format")
  signing_policy = get_env_or_warn("SIGNPATH_POLICY", "release-signing")

  # Check prerequisites
  if not api_token or not organization_id:
    msg = "SignPath credentials not configured - skipping signing"
    if args.fail_on_error:
      print(f"ERROR: {msg}", file=sys.stderr)
      sys.exit(1)
    else:
      print(f"WARNING: {msg}", file=sys.stderr)
      sys.exit(0)

  if not check_signpath_cli():
    msg = "SignPath CLI not available - skipping signing"
    if args.fail_on_error:
      print(f"ERROR: {msg}", file=sys.stderr)
      sys.exit(1)
    else:
      print(f"WARNING: {msg}", file=sys.stderr)
      sys.exit(0)

  # Attempt signing
  success = sign_artifact(artifact_path=args.artifact,
                          organization_id=organization_id,
                          project_slug=project_slug,
                          signing_policy_slug=signing_policy,
                          api_token=api_token,
                          artifact_config_slug=args.artifact_config,
                          timeout_minutes=args.timeout)

  if not success:
    if args.fail_on_error:
      sys.exit(1)
    else:
      print("WARNING: Signing failed, continuing with unsigned artifact", file=sys.stderr)
      sys.exit(0)

  sys.exit(0)


if __name__ == "__main__":
  main()
