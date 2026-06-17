# runx Windows Receipt Store Repro

Minimal public repro for a Windows-specific `runx` receipt-store bug.

## Bug

`runx` receipt ids commonly look like `sha256:...`.
The receipt store currently uses the raw receipt id as the on-disk JSON filename.
That works on Unix-like systems, but fails on Windows because `:` is not a valid filename character.

Observed symptom on Windows:

```text
receipt store is unreadable: 参数错误。 (os error 87)
```

## What this repo contains

- `hello-world/`: copied from the public `runxhq/runx` example skill
- `test.ps1`: minimal failing test that expects a healthy receipt-backed skill run
- `analysis.md`: root-cause analysis and fix direction

## Run

```powershell
powershell -ExecutionPolicy Bypass -File .\test.ps1
```

## Expected result today

The script should fail on Windows with a receipt-store error.
That failure is the bug proof.

## Expected result after a fix

The same script should exit 0 and create at least one receipt JSON file under `.tmp/receipts/`.