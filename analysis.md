# Analysis

## Impact

User-facing correctness bug on Windows.
Any `runx` flow that needs to persist receipts can fail even when the skill itself is otherwise valid.

## Minimal behavior under test

A basic `runx skill` invocation against the checked-in `hello-world` example should:

1. exit successfully
2. seal a receipt
3. write at least one receipt JSON file into the selected receipt store

On Windows, that currently fails.

## Root cause

In `crates/runx-runtime/src/receipts/store.rs`, `receipt_file_name(receipt_id)` currently returns:

```rust
Ok(format!("{receipt_id}.json"))
```

The function rejects `/` and `\\`, but it does not reject or encode `:`.
That is a problem because receipt ids commonly look like `sha256:...`.

So the store tries to materialize filenames like:

```text
sha256:abc123....json
```

That filename is invalid on Windows.

## Why this is substantial

The failure is not cosmetic:

- the CLI exits non-zero
- receipt-backed flows become unusable on Windows
- the bug affects the core receipt persistence path rather than one optional adapter

## Suggested fix direction

Use a platform-safe filename mapping instead of the raw receipt id.
Examples: percent-encoding, base64url/hex encoding, or a hash-based filename with the original receipt id stored in file contents/index metadata.

## Green condition after fix

`test.ps1` should exit 0 on Windows and `.tmp/receipts/` should contain at least one `.json` receipt file.