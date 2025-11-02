# Minimal ML Project Template

A minimal machine learning project template with essential tooling for dependency management, containerization, CI/CD, and code quality.

## Features

- **Environment Management**: `uv` for fast Python dependency management with `pyproject.toml`
- **Containerization**: Apptainer (Singularity) container support for reproducible environments
- **CI/CD**: GitHub Actions for automated code formatting checks (ruff) and unit testing (pytest)
- **Code Quality**: Pre-commit hooks with ruff for automatic code formatting and linting

## Project Structure

```
.
├── src/                    # Main source code
├── tests/                  # Unit tests
├── pyproject.toml         # Project configuration and dependencies
├── uv.lock               # Locked dependencies (generate with `uv lock`)
├── Apptainer.def         # Container definition file
├── .pre-commit-config.yaml # Pre-commit hooks configuration
├── .github/workflows/    # GitHub Actions workflows
└── Makefile              # Convenient command shortcuts
```

## Quick Start

### Prerequisites

- Python 3.11 or higher
- [uv](https://github.com/astral-sh/uv) package manager
- (Optional) Apptainer/Singularity for containerization

### Installation

1. **Clone and navigate to the project**:
   ```bash
   git clone <your-repo-url>
   cd min-project-template
   ```

2. **Install uv** (if not already installed):
   ```bash
   curl -LsSf https://astral.sh/uv/install.sh | sh
   ```

3. **Install dependencies**:
   ```bash
   uv sync --all-extras --dev
   ```
   
   Note: `--all-extras` is needed because dev dependencies are defined as optional dependencies in `pyproject.toml`.

4. **Generate lock file** (if not present):
   ```bash
   uv lock
   ```

5. **Activate the virtual environment**:
   ```bash
   source .venv/bin/activate  # On Unix/macOS
   # or
   .venv\Scripts\activate     # On Windows
   ```

6. **Install pre-commit hooks** (optional but recommended):
   ```bash
   uv run pre-commit install
   ```
   
   Or use the Makefile:
   ```bash
   make setup  # Installs dependencies and pre-commit hooks
   ```

## Development

### Using Makefile (Recommended)

The project includes a `Makefile` with convenient shortcuts for common tasks:

```bash
# Setup (install dependencies and pre-commit hooks)
make setup

# Code formatting and linting
make format          # Format code
make lint            # Lint code
make format-check    # Check formatting without modifying
make lint-fix        # Fix auto-fixable linting issues

# Testing
make test            # Run tests
make test-cov        # Run tests with coverage report

# Pre-commit
make pre-commit-install  # Install pre-commit hooks
make pre-commit-run     # Run pre-commit on all files

# Container
make build-container  # Build Apptainer container
make run-container CMD="python -c 'print(1)'"  # Run command in container

# Cleanup
make clean           # Remove cache and build artifacts

# See all available commands
make help
```

### Running Tests

```bash
# Run all tests
uv run pytest

# Run with coverage
uv run pytest --cov=ml_project_template --cov-report=html

# Run specific test file
uv run pytest tests/test_example.py
```

### Code Formatting and Linting

```bash
# Format code
uv run ruff format .

# Check formatting
uv run ruff format --check .

# Lint code
uv run ruff check .

# Fix auto-fixable issues
uv run ruff check --fix .
```

### Adding Dependencies

1. Add the dependency to `pyproject.toml` under `[project.dependencies]` (for production) or `[project.optional-dependencies.dev]` (for development)
2. Run `uv lock` to update the lock file
3. Run `uv sync --all-extras --dev` to install the new dependency (or `uv sync` for production dependencies only)

Example:
```bash
# Add a new dependency
uv add numpy  # Adds to [project.dependencies]
uv add --dev pytest-cov  # Adds to [project.optional-dependencies.dev]
```

## Containerization

### Building Apptainer Image

```bash
apptainer build image.sif Apptainer.def
```

Or use the Makefile:
```bash
make build-container
```

### Running with Apptainer

```bash
# Execute a Python command
apptainer exec image.sif python -c "print('Hello, World!')"

# Interactive shell
apptainer shell image.sif

# Run a command
apptainer exec image.sif uv run pytest
```

Or use the Makefile:
```bash
make run-container CMD="python -c 'print(1)'"
```

## GitHub Actions

The repository includes two GitHub Actions workflows:

1. **Format Check** (`.github/workflows/format-check.yml`):
   - Runs on pull requests and pushes to main/develop
   - Checks code formatting with ruff format
   - Runs ruff linting

2. **Unit Tests** (`.github/workflows/test.yml`):
   - Runs on pull requests and pushes to main/develop
   - Tests against Python 3.11 and 3.12
   - Generates coverage reports

## Pre-commit Hooks

Pre-commit hooks automatically run before each commit to ensure code quality:

- Trailing whitespace removal
- End-of-file fixes
- YAML/JSON/TOML validation
- Ruff formatting and linting

To bypass pre-commit hooks (not recommended):
```bash
git commit --no-verify -m "message"
```

## Contributing

1. Create a feature branch from `main`
2. Make your changes
3. Ensure code passes ruff checks: `uv run ruff format . && uv run ruff check .`
4. Write/update tests and ensure they pass: `uv run pytest`
5. Commit (pre-commit hooks will run automatically)
6. Push and create a pull request

## License

MIT License.

## Additional Resources

- [uv Documentation](https://github.com/astral-sh/uv)
- [Apptainer Documentation](https://apptainer.org/docs/)
- [Ruff Documentation](https://docs.astral.sh/ruff/)
- [pytest Documentation](https://docs.pytest.org/)

