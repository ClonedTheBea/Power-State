# R3.7 owner upload package

**Integration update:** the owner uploaded this exact file as Decal `138420314032574`. Test Studio resolved its Texture and ColorMap to Image `90608851718773`; both metadata records identify missawfulname / 149564436. See `roblox-verification.json` and the current R3.7 validation report. Do not upload it again. The instructions below are retained as the preparation record; `manifest.json` preserves the pre-upload placement specification.

Upload **only `power-state-settlements-proof-v1.png`**, a 512×256 RGBA PNG containing both accepted settlements. It is byte-identical to the R3.6 study atlas; only its filename changes. Neither accepted motif was regenerated, recoloured or repacked.

SHA-256: `baff92a631e89bbf9a1506f5401488e40fc2d5fe56a71399b1f410df5b05ff4e`

## Owner-operated upload

1. Recheck the file with `Get-FileHash -Algorithm SHA256 'assets/r37-settlements-v1/power-state-settlements-proof-v1.png'` from the project root.
2. Open Creator Dashboard Development Items under your personal **missawfulname** account (User ID **149564436**). Verify the dialogue says **Uploading to missawfulname**, not a group.
3. Confirm new assets are **Restricted**. If the destination/privacy differs, stop; this task authorizes no settings or permission changes.
4. Select the exact PNG above, with a descriptive name such as `Power State Settlements Proof v1`. Do not select the contact sheet, terrain board, manifest or original six-motif atlas. Perform the upload yourself when ready.
5. Intended isolated consumer: **Power States - Test**, Universe **10776833313**. Do not associate changes with Production **10776828545** or publish the game. Same-owner access must still be tested after upload; prior atlas success does not prove this new asset's permissions.
6. Supply the resulting asset ID and whether Dashboard identifies it as Image or Decal. If Roblox returns a Decal container, its actual image dependency must be verified before configuring an ImageLabel; never guess an ID or reuse the old atlas's image ID.

No upload or privacy/permission verification has been performed in this task. If delivery is denied, report the failure before considering any separate permission change.

`manifest.json` records candidate placement and upload metadata; `assetId` is null. It is not loaded by the game. `alignment-five-zooms.png` is a local annotated comparison, not a Studio screenshot. `prepare.py` validates approved bytes, copies them, checks bounds/alpha/coordinate transforms and produces the review materials. It uses existing Pillow and does not modify runtime or old packages. Original source artwork and exact prompts remain in `../r36-study-v1/`.

See [R3.7 readiness and validation](../../docs/R37-VALIDATION.md) for the upload boundary and next implementation steps.
