# DASMLAB Security Suite — Project Design & Architecture

## Purpose

This project aims to provide a single, composable security scanning suite that can be dropped into any modern CI/CD workflow, bundling the most effective open source tools for SAST and DAST testing. This provides boilerplate for NIST-53, CVE and other compliancy work to come

---

## High-Level Design

┌────────────────────────────────────┐
│ dasmlab_security_suite:latest │
│ │
│ +-----------------------------+ │
│ | entrypoint.sh | │
│ +-----------------------------+ │
│ ↓ orchestrates scans │
│ +---------+ +--------+ +-------+
│ | SAST | | DAST | | CONTAINER SCAN |
│ +---------+ +--------+ +-------+
│ Trivy, Nikto, Trivy, Grype, etc
│ Semgrep, ZAP, etc
│ Bandit, etc
│ ↓ ↓ ↓
│ Output reports to /output/
└────────────────────────────────────┘

yaml
Copy
Edit

---

## Directory Structure

dasmlab_security_suite/
├─ Dockerfile
├─ entrypoint.sh # Orchestrates all scans
├─ sast/ # Static code analysis scripts/tools
│ ├─ run_sast.sh
│ └─ configs/...
├─ dast/ # Runtime scan scripts/tools
│ ├─ run_dast.sh
│ └─ configs/...
├─ output/ # Default output directory for artifacts
└─ README.md

yaml
Copy
Edit

---

## Toolchain

### SAST
- **Trivy**: Source code and secrets scan.
- **Semgrep**: Fast static analysis, custom rule support.
- **Bandit**: (Optional) Python-specific static analysis.

### DAST
- **Nikto**: Lightweight web scanner.
- **OWASP ZAP**: (Optional/future) Advanced DAST and API testing.

### Container Scanning
- **Trivy**: Scan built images for CVEs, misconfig, secrets.

---

## Entrypoint Orchestration

- Accepts environment variables for code location, container name, endpoint, etc.
- Runs SAST tools on mounted source.
- Runs container scan against provided container.
- Runs DAST tools against the live endpoint (if reachable).
- Collects all output into `/output` (or specified mount).

---

## Extending

- Drop additional scripts or configs into `/sast` or `/dast`.
- Add install steps to Dockerfile for new tools.
- Add more report collectors, integrate custom policies, or API tests.

---

## Security & Performance

- Designed to run in ephemeral, isolated CI runners with minimal risk.
- Output directory is always mounted for artifact upload.
- Sensitive credentials should **never** be required.

---

## Roadmap

- Add optional ZAP and API fuzzing modules.
- Add customizable rule support for semgrep/bandit.
- Integrate SBOM export and license scans.
- Support "fail on findings" mode for gating builds.

---

## Authors / Credits

DASMLAB Security Engineering  
Based on best practices from OWASP, Aqua Security, and open source security community.

---

**See [README.md](./README.md) for usage instructions.**
