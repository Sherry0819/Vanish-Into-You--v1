# Vanish Into You

**Vanish Into You** is a decentralized digital legacy protocol for (1) on-chain inheritance and (2) off-chain legacy delivery,
augmented by a privacy-preserving **Digital Profile** module.

**Core idea**: *Smart contracts decide **when** access is unlocked; encrypted off-chain modules decide **what** is delivered and **how** it is represented.*

## What’s included in this repo

### On-chain (design + contract skeletons)
- `InheritanceVault.sol`: inactivity / attestation triggers, challenge window, distribution execution
- `LegacyRegistry.sol`: registers encrypted legacy bundles and releases access upon vault execution

> These contracts are intentionally minimal and heavily documented so the design is easy to audit and extend.

### Off-chain (working code)
- `Digital Profile`: builds a structured, interpretable portrait from authorized text
- `Style Writer`: rewrites a message in a person’s writing style (no LLM required; deterministic + explainable)
- `Bundle Encryption`: encrypt/decrypt a legacy bundle (AES-GCM) locally (demo-grade)
---

## Quickstart (Digital Profile demo)

```bash
python -m venv .venv
source .venv/bin/activate    # Windows: .venv\Scripts\activate
pip install -r requirements.txt

python offchain/digital_profile/build_profile.py --input data/sample/example_texts_en.txt --out reports/persona_profile.json
python offchain/digital_profile/generate_memorial.py --profile reports/persona_profile.json --out reports/portrait.md
python offchain/digital_profile/style_rewrite.py --profile reports/persona_profile.json --text "Thank you for remembering me."
```

Outputs:
- `reports/persona_profile.json`
- `reports/portrait.md`

---

## Integration: “unlock after inheritance”
The intended flow is:

1) User registers an encrypted legacy bundle in `LegacyRegistry` (CID + hash + encrypted key for each beneficiary).
2) `InheritanceVault` determines eligibility (inactivity / attestations / joint notice) and finalizes distribution.
3) On execution, `InheritanceVault` calls `LegacyRegistry.releaseAccess(...)` to emit an on-chain event for beneficiaries.
4) Beneficiaries fetch the released encrypted key and decrypt the off-chain bundle locally.

See:
- `contracts/InheritanceVault.sol`
- `contracts/LegacyRegistry.sol`
- `docs/design.md`

---

## Disclaimer
This is a research & engineering prototype and is not legal/medical/financial advice.
