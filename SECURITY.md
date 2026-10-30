# Security Policy

## Code Signing Policy

Free code signing provided by [SignPath.io](https://signpath.io), certificate by [SignPath Foundation](https://signpath.org).

### Team Roles

| Role | Member |
|------|--------|
| **Author / Committer** | [Ashley Harris](https://github.com/ashleyharris-maptek-com-au) |
| **Reviewer** | [Ashley Harris](https://github.com/ashleyharris-maptek-com-au) |
| **Approver** | [Ashley Harris](https://github.com/ashleyharris-maptek-com-au) |

All team members use multi-factor authentication for both SignPath and GitHub access.

### Signed Artifacts

The following artifacts are signed when released:
- `scad-format.exe` - Windows executable (Authenticode)
- `scad-format-*-setup.exe` - Windows installer (Authenticode)

## Privacy Policy

**This program will not transfer any information to other networked systems unless specifically requested by the user or the person installing or operating it.**

scad-format is a local code formatting tool that:
- Processes files entirely on your local machine
- Does not collect any user data
- Does not make any network connections
- Does not contain telemetry or analytics
- Does not send crash reports

### Third-Party Components

scad-format uses the following open source dependencies, none of which collect user data when used as part of this application:
- Python standard library
- PyInstaller (build-time only)

## Reporting Security Vulnerabilities

If you discover a security vulnerability in scad-format, please report it by:

1. **Email**: Contact the maintainer directly (do not open a public issue)
2. **GitHub Security Advisories**: Use GitHub's private vulnerability reporting feature

Please include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Any suggested fixes

We will acknowledge receipt within 48 hours and provide a timeline for resolution.

## Supported Versions

| Version | Supported |
|---------|-----------|
| 1.x.x   | ✅ Yes    |
| < 1.0   | ❌ No     |
