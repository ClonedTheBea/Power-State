# V1.2 ground material — rejected candidates

Neither candidate is upload-ready. Both built-in image-generation outputs are1254x1254 instead of1024x1024, have wrapping discontinuities and visible repeated brush structure. Original pixels are retained. See [gate report](../../docs/ILLUSTRATED-WORLD-V12-VALIDATION.md).

`candidate-edit.png` refines the retained v1.1 candidate; `candidate-new.png` is a fresh generation without reference inputs. `provenance.json` records exact prompts, source paths and hashes. Prompt records and the contact/measurement script are editable sources; there is no layered painting source. AI generation does not establish exclusive rights or a legal clearance. No new external reference artwork, dependency or Roblox asset was introduced.

Run `python assets/illustrated-world-v12-ground-study/validate_and_preview.py` from the repository to regenerate local diagnostics using existing Pillow/numpy. It never edits the candidate files. Preview resampling, motif compositing and colour swatches are diagnostic only. Full-resolution repeat files preserve original source pixels. The256-subdivision images use the top-left1024 region only, explicitly not a corrected final tile. `motif-zoom-contact.png` uses unchanged approved atlas crops at .55/.72/1/1.2/1.8; its ground is a material swatch rather than world sampling. Uniform elevation swatches are not a continuous-gradient proof.

Review `candidate-edit-contact.png`, `candidate-new-contact.png` and `motif-zoom-contact.png`. Do not upload, integrate or substitute either candidate for the approved atlases. Next production attempt needs controlled periodic seam painting, exact1024 dimensions, reduced diagonal repetition and palette correction before the dependent country-compositing study.
