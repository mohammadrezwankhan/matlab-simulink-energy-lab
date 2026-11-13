# Security Policy

## Scope & Operational Context
The **MATLAB & Simulink Energy Lab** repository provides reference models, simulation harnesses, and parameter identification scripts for lithium-ion battery electro-thermal dynamics and grid-forming/following inverter control. These models are intended for research, simulation, and hardware-in-the-loop (HIL) design.

The simulation files and scripts execute within local MATLAB/Simulink runtime environments. They do not initiate external unauthenticated network requests, bind public network listeners, or manage persistent credentials.

## Reporting Security Vulnerabilities
If you identify a security issue, potential vulnerability, or supply chain weakness in any workflow, script, or model:
1. **Do not disclose the issue publicly** via issues, discussions, or pull requests.
2. Submit a report privately via **GitHub Private Vulnerability Reporting** on this repository.
3. If private reporting is unavailable, reach out directly to the maintainer via the verified GitHub account [mohammadrezwankhan](https://github.com/mohammadrezwankhan).

## Vulnerability Handling & Response SLA
- **Acknowledgement**: Within 48 hours of initial report receipt.
- **Triage & Validation**: Within 5 business days, including risk severity classification (CVSS v3.1).
- **Remediation & Patch**: Target delivery within 14 days for high/critical vulnerabilities.
- **Coordinated Disclosure**: Publication of a security advisory and patched release only after verified deployment of the fix.

## Security Practices for Contributors
- Never commit real credentials, proprietary telemetry, or non-anonymized field data.
- Ensure all automated workflows (`.github/workflows/`) enforce least-privilege token permissions (`permissions: read-all` or explicit scopes).
- Verify input bounds and validate synthetic test datasets before merging.
