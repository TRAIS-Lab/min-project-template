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
   git clone https://github.com/TRAIS-Lab/min-project-template.git
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
# --fakeroot: Build without root privileges (requires fakeroot to be configured)
apptainer build --fakeroot image.sif Apptainer.def
```

Or use the Makefile:
```bash
make build-container
```

### Running with Apptainer

```bash
# Run a command with advanced options
# --nv: Enable NVIDIA GPU support (mounts GPU drivers and libraries)
# --cleanenv: Clean environment variables, only keep minimal set
# --bind "$PWD":/work: Bind mount current directory to /work in container
# --pwd /work: Set working directory to /work inside container
# bash -lc: Run bash as login shell to source profile scripts
# set -euo pipefail: Bash safety options (-e: exit on error, -u: error on unset vars, -o pipefail: fail pipeline on any error)
# Multiple bash commands can be separated by semicolons or newlines
apptainer exec --nv --cleanenv --bind "$PWD":/work --pwd /work image.sif bash -lc '
    set -euo pipefail
    uv run ruff format .
    uv run pytest
'

# Interactive shell (opens an interactive shell inside the container)
apptainer shell image.sif
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

## Best Practices for Reproducible ML Research

Reproducibility is crucial for scientific research. Follow these practices to ensure your experiments can be replicated:

### 1. Random Seed Management

Always set random seeds for reproducibility:

```python
import random
import numpy as np
import torch  # if using PyTorch

# Set seeds
SEED = 42
random.seed(SEED)
np.random.seed(SEED)
torch.manual_seed(SEED)
if torch.cuda.is_available():
    torch.cuda.manual_seed_all(SEED)
```

**Best Practice**: Store the seed value in your configuration files and log it with your experiment tracking system.

### 2. Environment Reproducibility

- **Lock dependencies**: Always commit `uv.lock` to version control
  ```bash
  # After modifying pyproject.toml, update and commit lock file
  uv lock
  git add uv.lock pyproject.toml
  git commit -m "Update dependencies and lock file"
  ```

- **Use containers**: Build Apptainer containers for experiments to ensure consistent environments
  ```bash
  # Build container from definition file
  apptainer build --fakeroot image.sif Apptainer.def
  
  # Run experiments in container
  apptainer exec --nv --cleanenv --bind "$PWD":/work --pwd /work image.sif bash -lc '
      set -euo pipefail
      python -m src.train
  '
  
  # Or use Makefile
  make build-container
  make run-container CMD="python -m src.train"
  ```

- **Document Python version**: Specify exact Python version in `Apptainer.def` and `pyproject.toml`
  ```bash
  # Check current Python version
  python --version
  
  # In pyproject.toml, specify:
  # requires-python = ">=3.11,<3.12"  # For exact version
  # requires-python = ">=3.11"         # For minimum version
  
  # In Apptainer.def, use specific base image:
  # From: python:3.11.5-slim  # Specific version
  # From: python:3.11-slim     # Minor version
  ```

- **Freeze system packages**: Document any system-level dependencies or CUDA versions
  ```bash
  # Check CUDA version (if using GPUs)
  nvidia-smi
  
  # Check system packages
  pip list  # Python packages
  apt list --installed  # Debian/Ubuntu (if in container)
  
  # Document in Apptainer.def or create requirements-system.txt
  # Example in Apptainer.def:
  # %post
  #     apt-get update
  #     apt-get install -y cuda-toolkit-11-8  # Document specific version
  ```

### 3. Experiment Tracking

- **Log everything**: Hyperparameters, model architecture, data splits, preprocessing steps
- **Use tags**: Tag experiments by purpose (e.g., `baseline`, `ablation`, `final`)
- **Version datasets**: Document dataset versions, splits, and preprocessing
- **Save configurations**: Define hyperparameters in your code or configuration files and commit them to git for each experiment

```python
# Example experiment logging
config = {
    "learning_rate": 0.001,
    "batch_size": 32,
    "seed": 42,
    "model": "transformer",
    "dataset_version": "v1.0",
}
# Log with your experiment tracking system
```

### 4. Data Management

- **Document data sources**: Include data acquisition date, source, and preprocessing steps
- **Version control splits**: Save train/val/test split indices or use deterministic splitting
- **Data checksums**: Compute and store checksums for datasets to verify integrity
- **Data documentation**: Create `data/README.md` describing datasets and their structure

### 5. Configuration Management

- **Centralize configs**: Store all hyperparameters in configuration files or constants in your code (consider creating a `config/` directory as your project grows)
- **Version configs**: Commit configuration files or code with hyperparameters to track changes
- **Use YAML/JSON**: Human-readable formats (YAML/JSON files) for easier review and modification, or define configs as Python dictionaries
- **Environment variables**: Use `.env` files for sensitive information (never commit secrets to version control)

### 6. Checkpoint Management

- **Save checkpoints regularly**: Enable automatic checkpointing during training
- **Metadata with checkpoints**: Save configuration, seed, and git commit hash with each checkpoint
- **Naming conventions**: Use clear naming (e.g., `model_epoch_10_seed_42_commit_abc123.pt`)
- **Document best models**: Track which checkpoints correspond to reported results

### 7. Code Versioning

- **Git tags for experiments**: Tag git commits for each experiment or paper submission
  ```bash
  git tag -a v1.0-baseline -m "Baseline experiment results"
  git tag -a paper-v1.0 -m "Code version for paper submission"
  ```
- **Commit before experiments**: Always commit code before running experiments
- **Document branches**: Use descriptive branch names for experimental variants
- **Link results to commits**: Reference git commit hashes in papers and reports

### 8. Results Documentation

- **Report statistics**: Document mean and standard deviation across multiple runs
- **Save predictions**: Store model predictions for later analysis
- **Logging consistency**: Use consistent logging formats across experiments
- **Results README**: Create `results/README.md` linking experiments to configurations

### 9. Reproducibility Checklist

Before publishing or sharing results, verify:

- [ ] Random seeds are set and documented
- [ ] All dependencies are pinned in `uv.lock`
- [ ] Hyperparameters and configurations are committed (in code or config files)
- [ ] Experiment runs are logged and tagged appropriately
- [ ] Data preprocessing steps are documented
- [ ] Code is committed with descriptive messages
- [ ] Git tags mark important experiment versions
- [ ] Checkpoints include metadata (seed, config, commit hash)
- [ ] Container can reproduce the environment
- [ ] README documents how to run experiments

### 10. Example Reproducible Experiment Workflow

```python
# src/train.py
import git
from datetime import datetime

# Get git commit hash for reproducibility
repo = git.Repo(search_parent_directories=True)
commit_hash = repo.head.object.hexsha[:7]

# Initialize experiment tracking with comprehensive logging
config = {
    **hyperparameters,  # Your config dict
    "git_commit": commit_hash,
    "timestamp": datetime.now().isoformat(),
}

# Set seeds (from config)
set_all_seeds(config["seed"])

# Train model...
```

### Additional Resources

- [ML Reproducibility Checklist](https://www.cs.mcgill.ca/~jpineau/ReproducibilityChecklist.pdf)
- [Papers with Code Reproducibility](https://paperswithcode.com/)
- [The Turing Way: Reproducible Research](https://the-turing-way.netlify.app/reproducible-research/reproducible-research.html)

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

