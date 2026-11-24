# LITD 1 exploration validator — V1.10

This directory is an isolated publication of the V1.10 validator archive. It is a design-time validator and test suite; it is not wired into Godot or the runtime save manager.

The files named `graph_v0.*.reconstructed.json` are archive artifacts and are retained under their explicit reconstructed names. The repository originals under `docs/conception/exploration/graph_v0.*` are not replaced or edited.

## Verify transferred archive files

From this directory, run `sha256sum -c SHA256SUMS.txt`. The manifest covers the 43 files transferred from the archive and excludes itself and this README.

## Run tests

`python -m pip install -r requirements.txt`

`python -m unittest discover -s . -p 'test_*.py' -v`

The CI workflow pins `jsonschema==4.26.0` and runs the full suite for pull requests targeting `feat/litd-exploration-validator-v18`.
