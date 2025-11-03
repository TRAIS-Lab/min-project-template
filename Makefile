.PHONY: help install install-dev format lint test test-cov clean lock pre-commit-install pre-commit-run build-container run-container

# Default target
help:
	@echo "Available commands:"
	@echo "  make install           - Install production dependencies"
	@echo "  make install-dev       - Install development dependencies"
	@echo "  make lock              - Update lock file"
	@echo "  make format            - Format code with ruff"
	@echo "  make lint              - Lint code with ruff"
	@echo "  make test              - Run tests"
	@echo "  make test-cov          - Run tests with coverage report"
	@echo "  make pre-commit-install - Install pre-commit hooks"
	@echo "  make pre-commit-run    - Run pre-commit on all files"
	@echo "  make clean             - Clean cache and build artifacts"
	@echo "  make build-container   - Build Apptainer container"
	@echo "  make run-container     - Run command in container (usage: make run-container CMD='python -m src.train')"

# Installation
install:
	uv sync

install-dev:
	uv sync --all-extras --dev

lock:
	uv lock

# Code quality
format:
	uv run ruff format .

lint:
	uv run ruff check .

format-check:
	uv run ruff format --check .

lint-fix:
	uv run ruff check --fix .

# Testing
test:
	uv run pytest

test-cov:
	uv run pytest --cov=ml_project_template --cov-report=html --cov-report=term-missing

# Pre-commit
pre-commit-install:
	uv run pre-commit install

pre-commit-run:
	uv run pre-commit run --all-files

# Containerization
build-container:
	apptainer build --fakeroot image.sif Apptainer.def

run-container:
	@if [ -z "$(CMD)" ]; then \
		echo "Usage: make run-container CMD='python -m src.train'"; \
		echo "       Or multiple commands: make run-container CMD='uv run ruff format . && uv run pytest'"; \
		exit 1; \
	fi
	apptainer exec --nv --cleanenv --bind "$(CURDIR)":/work --pwd /work image.sif bash -lc "set -euo pipefail; $(CMD)"

# Cleanup
clean:
	find . -type d -name "__pycache__" -exec rm -r {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	find . -type f -name "*.pyo" -delete
	find . -type d -name "*.egg-info" -exec rm -r {} + 2>/dev/null || true
	find . -type d -name ".pytest_cache" -exec rm -r {} + 2>/dev/null || true
	find . -type d -name ".ruff_cache" -exec rm -r {} + 2>/dev/null || true
	find . -type d -name "htmlcov" -exec rm -r {} + 2>/dev/null || true
	find . -type f -name ".coverage" -delete
	find . -type f -name "coverage.xml" -delete
	rm -f image.sif 2>/dev/null || true
	@echo "Cleaned cache and build artifacts"

# Combined quality check (useful for CI)
check: format-check lint test
	@echo "All checks passed!"

# Setup for new contributors
setup: install-dev pre-commit-install
	@echo "Setup complete! Run 'make test' to verify installation."

