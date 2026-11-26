# Native save lock: integration gates

Verified commit `d9bb6fb87e07affccd46b4de4d1304d7bc3a8169`: 11/11 workflows successful. Run 45344027770, Linux job 138274147276 and Windows job 138274147187: each compiled with warnings as errors, two Python tests passed, and emitted NATIVE_SAVE_LOCK_PASS after native subprocess contention and forced termination checks.

This proves the isolated native executable on CI runners, not Godot integration or production durability.

## Proposed interface

Expose a RefCounted laboratory lock owner with try_acquire(absolute_path), release(), and is_held(). Own the existing CampaignLock by composition, prohibit copying, and retain the owner across the complete read/validate/journal/anchor/readback transaction. Fail closed if extension is unavailable. No Python runtime dependency. Use a single stable campaign lock path; never unlink it. Restrict initial integration to isolated laboratory paths. Validate canonical path identity and reject path escapes and aliases. No production SaveManager hookup until verified.

## Gates

1. Verify official godot-cpp compatibility with the project's pinned Godot 4.7.2, pin an immutable dependency revision and record provenance/license. Do not guess a tag.
2. Build extension for Linux and Windows, verify load and registered class in isolated Godot project.
3. Exercise two actual Godot processes against one lock, normal exit and forced termination; test missing extension and invalid paths.
4. Hold lock over the full coordinator and explicit resolution; test concurrent writers and stale approvals, pending anchors and crash recovery.
5. Validate packaged Windows build and migration/recovery before production integration.

Known limits: cooperating processes only; local filesystem assumptions; no proof of power-loss durability, network filesystem behavior, or malicious local path replacement. A native lock does not resolve loss of both journal and anchor tails.
