# Contributing to scad-format

## Development Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/ashleyharris-maptek-com-au/scad-format.git
   cd scad-format
   ```

2. Install development dependencies:

   ```bash
   pip install -e .[dev]
   ```

3. Run tests:

   ```bash
   python -m pytest tests/ -v
   ```

## Building Distributions

### Windows Executable

```bash
# Install build dependencies
pip install -e .[build]

# Run the build script
build_windows.bat
```

This creates:

- `dist/scad-format.exe` - Standalone executable
- `dist/scad-format-<version>-windows.zip` - Distribution package

### Windows Installer (requires NSIS)

1. Install [NSIS](https://nsis.sourceforge.io/Download)
2. Build the executable first (see above)
3. Run:

   ```bash
   cd installer
   makensis scad-format.nsi
   ```

### Python Package (wheel/sdist)

```bash
pip install build
python -m build
```

This creates:

- `dist/scad_format-<version>.tar.gz` - Source distribution
- `dist/scad_format-<version>-py3-none-any.whl` - Wheel

## GitHub Branch Protection Setup

To require tests to pass before merging PRs:

1. Go to **Settings** → **Branches** in your GitHub repository
2. Click **Add rule** (or edit existing rule for `main`/`master`)
3. Set **Branch name pattern**: `main` (or `master`)
4. Enable:
   - ☑️ **Require a pull request before merging**
   - ☑️ **Require status checks to pass before merging**
     - Search and select: `Run Tests (3.11)` (or whichever Python version you want as the gate)
   - ☑️ **Require branches to be up to date before merging**
5. Click **Save changes**

## CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/ci.yml`) automatically:

1. **Tests** - Runs on every push/PR across Python 3.8-3.12 on Linux
2. **Windows Build** - Creates the standalone executable
3. **Windows Installer** - Builds the NSIS installer (if NSIS available)
4. **PyPI Packages** - Builds sdist and wheel, validates with twine

Artifacts are uploaded and can be downloaded from the workflow run.

## Code Style

- Follow existing code patterns
- Add tests for new features
- Run `python -m pytest tests/ -v` before submitting PRs
