# Social preview v3

## Purpose and provenance

A new conceptual repository banner for MATLAB Simulink Energy Lab, created on
2026-09-09 using the built-in image-generation tool and reviewed against the
repository scope at main `9347aab85dccdad2e1dde8a85552fee14ec301bd`.

The four independent tiles represent battery/SOC, thermal, converter, and BESS
example families. The artwork is not a numerical result, integrated-system
model, hardware depiction validated by the code, performance benchmark, or
MathWorks endorsement. It contains no version, test count, star target, or
claim of adoption or certification. The voluntary star invitation remains in
the README, separate from the artwork. No improvement in star growth is claimed.

## Assets and usage

- `social-preview-v3.png`: original selected generated raster, 1774 × 887,
  1,449,365 bytes; preserved without overwriting the previous v2 image.
- `social-preview-v3.jpg`: JPEG quality-92 web export of the same composition,
  with no resizing or artwork changes. Used by the README to reduce transfer
  size: 240,305 bytes. This is an export, not another AI-generated version.
  SHA-256: `AEC3B4028437E1CE7ABCB29BE3C4E0B4EDFBA99130AFFF2A9CE42B34096D8DB5`.
- The image is exactly 2:1. Its title, model-family labels, full repository URL,
  and educational boundary were visually checked.
- The initial generated candidate included decorative solar/wind scenery. It
  was rejected because the repository does not offer those standalone model
  families. A targeted image-generation edit removed that scenery.
- The README image links to the runnable first-example section. Its caption
  explicitly distinguishes conceptual artwork from numerical evidence.

A README image does **not** configure GitHub's repository social-preview image.
That upload is a separate repository-settings action. GitHub documents PNG,
JPG, or GIF under 1 MB, at least 640 × 320, with 1280 × 640 recommended:
[GitHub social-preview documentation](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/customizing-your-repositorys-social-media-preview).
Do not claim a social-platform cache was refreshed merely because this file
was added or the repository settings changed.

## Initial generation prompt

```text
Use case: ads-marketing
Asset type: premium GitHub repository social-preview and README hero banner, wide 2:1 canvas, target 1280 x 640 pixels.
Primary request: create a completely new, striking but technically credible banner for the open-source "MATLAB Simulink Energy Lab", a collection of runnable reduced-order educational energy-system reference models. Designed to help relevant engineers and students understand the repository instantly, not to beg for stars.
Style: precise editorial engineering illustration with crisp typography, clean vector-like linework, subtle dimensional depth, and disciplined whitespace. Use the repository's navy, teal and off-white visual identity. Dark midnight navy background, luminous but restrained teal accents, bright off-white text, very faint technical grid only on the illustration area. No generic futuristic neon, no lens flares.
Composition: follow a clear text-left / illustration-right structure suited to the existing project banner. About 53 percent text area and 47 percent illustrative area. Generous 48-pixel safe margins. Title is overwhelmingly the main focus, readable when the banner is reduced to 640 x 320.
Text, render exactly and only the following:
Title on two lines, very large bold modern sans-serif:
"MATLAB Simulink"
"Energy Lab"
Subtitle in readable medium weight:
"Runnable models. Inspectable assumptions."
Small supporting line:
"MATLAB + Simulink"
Bottom-left label:
"Reduced-order educational models"
Footer across lower edge, readable but secondary:
"github.com/mohammadrezwankhan/matlab-simulink-energy-lab"
On the right: four clearly SEPARATE, beautifully aligned compact illustration panels in a 2-by-2 grid. Each panel has one bold short label and one attractive, simplified engineering illustration.
Panel labels exactly:
"BATTERY & SOC"
"THERMAL"
"CONVERTERS"
"BESS CONTROL"
Battery panel: stylized battery cell plus an abstract smooth SOC line; no numbers, axes, or measured data.
Thermal panel: stylized cell stack with a restrained teal-to-warm thermal gradient, not a physical simulation result.
Converters panel: tasteful simplified block-diagram motif with PWM pulse and smooth signal icon, NOT a detailed or purported working circuit schematic.
BESS panel: storage cabinet silhouette with a restrained sine-wave and minimal control-node motif, not a certified physical installation.
Use only these four model-family panels; NO arrows between the panels. They are independent example families, not a single connected plant.
Constraints: no test counts, no release version, no star count or 512 target, no stars/trophies, no "champion", no "validated" badge, no "production ready", no certification/official MathWorks endorsement, no fake performance graph, no hardware-validation claim, no people, no QR code, no tiny explanatory paragraphs, no logos copied from MATLAB or GitHub, no watermark. Ensure "Simulink" and the full repository URL are spelled perfectly. All lettering is sharp and unclipped. The four illustrations are conceptual branding, not numerical evidence. Output one polished, cohesive, publication-quality raster image.
```

## Targeted correction prompt

```text
Use case: precise-object-edit.
Edit target: the attached generated MATLAB Simulink Energy Lab banner.
Make ONE targeted correction: completely remove the entire decorative landscape beneath the "MATLAB + Simulink" text, including ALL solar panels, wind turbines, mountains, lake, trees, transmission towers, and city silhouettes. Replace that lower-left scenic area with clean, mostly flat midnight-navy negative space and only a very restrained teal ambient gradient, matching the existing background.
Preserve EXACTLY the title, subtitle, all other text including URL and disclaimer, the four right-side model-family panels, all panel illustrations, typography, scale, alignment, spacing, and overall 2:1 composition. Do not introduce new objects, logos, plots, numbers, or claims. No solar or wind imagery anywhere. This is an open-source collection of four independent model families, not a full renewable plant.
Keep all text verbatim and crisp. Maintain all existing safe margins and the off-white/navy/teal identity. If supported, export a web-optimized 1280 x 640 PNG under 1 MB, without changing the 2:1 aspect ratio or cropping any content. Do not sacrifice legibility. Produce the final corrected banner.
```

Generated using the built-in tool, not the CLI/API fallback. The old
`generate_social_preview.m` remains a legacy generator and does not reproduce
this AI-created artwork or its typography.
