---
name: Gotcha report
description: Battle-tested knowledge from your own OpenClaw deployment
labels: ["gotcha"]
body:
  - type: markdown
    attributes:
      value: |
        Gotchas are the most valuable contributions to this repo — operational lessons
        that cost you real time. The stricter the evidence, the more useful it is.
  - type: input
    id: version
    attributes:
      label: OpenClaw version
      description: Exact version this was true on (`npm view openclaw version` or your install)
      placeholder: e.g. 2026.11.1
    validations:
      required: true
  - type: dropdown
    id: platform
    attributes:
      label: Platform
      options:
        - Linux (systemd)
        - Windows (scheduled task)
        - Docker / container
        - macOS
    validations:
      required: true
  - type: textarea
    id: signal
    attributes:
      label: Signal
      description: What you saw — symptom, error, log line
    validations:
      required: true
  - type: textarea
    id: diagnosis
    attributes:
      label: Diagnosis
      description: What it actually was, once you knew
    validations:
      required: true
  - type: textarea
    id: fix
    attributes:
      label: Fix
      description: What worked, reproducibly
    validations:
      required: true
  - type: textarea
    id: evidence
    attributes:
      label: Evidence
      description: Doc URL, release-note link, or minimal repro. Optional but upgrades your gotcha's trust level.
  - type: checkboxes
    id: anon
    attributes:
      label: Anonymization
      options:
        - label: I confirm this report contains no identifying details from my deployment (names, hostnames, IPs, providers)
        - label: I confirm this gotcha is not already fully documented upstream (link it instead)
