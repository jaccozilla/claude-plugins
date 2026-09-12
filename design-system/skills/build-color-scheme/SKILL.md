---
name: build-color-scheme
description: Generate a Material 3 light/dark color scheme from a seed color or an image using the Material Theme Builder web tool (material-foundation.github.io/material-theme-builder), then apply the result into the project's own design-system theme file. Use when the user asks to change the brand/seed color, generate a new color scheme or palette, rebrand the app's colors, or pick colors from a logo/image.
---

# Build a Material 3 color scheme

Generates a real Material 3 tonal color scheme (all ~30 `ColorScheme`
roles, light and dark) from either a single seed color or an image, using
Google's own [Material Theme
Builder](https://material-foundation.github.io/material-theme-builder/) —
the reference implementation of the HCT/tonal-palette algorithm M3 itself
is built on — then writes the result into the project's design-system
theme file.

**This skill doesn't hardcode any project's theme file layout.** Every
project consuming this may structure its theme differently — find the real
structure before generating anything.

## Step 1: Find the project's theme file and current approach

1. Search for the project's design-system/theme file — usually named
   `Theme.kt`, `Color.kt`, or similar, under a `designsystem`/`theme`
   package. A project's top-level agent-instructions file (`CLAUDE.md`)
   often names a "Design system" convention pointing at it directly, and
   may reference a `docs/decisions/*material*.md` ADR or
   `docs/patterns/*material*.md` pattern doc explaining the project's own
   rules — read those first if present, since they may add extra
   constraints (an approval gate before changing hardcoded values, a
   specific `PaletteStyle`/variant already chosen, etc.).
2. Read the file and determine which of two shapes it's in:
   - **Stock M3 builders** — `lightColorScheme(...)`/`darkColorScheme(...)`
     (`androidx.compose.material3`), with roles either defaulted or
     individually hand-set. This skill's output replaces these calls'
     arguments with the full generated role set.
   - **A seed-color generator library** (e.g.
     [MaterialKolor](https://github.com/jordond/MaterialKolor)'s
     `dynamicColorScheme(seedColor, isDark, style)`) — the whole palette
     already derives from one seed constant at build time. This skill's
     output is just that one seed color (and, if the library exposes it,
     the closest matching `style`/variant); don't paste a full literal
     role list into a file that's designed to generate it at runtime.
3. Note the file's existing structure (imports, surrounding declarations
   like a `PillShape` or `Typography`) so your edit only touches the color
   values, not anything else in the file.

If neither shape is present (no theme file, or colors defined some other
way entirely), ask the user where the generated scheme should go before
proceeding.

## Step 2: Get the seed input

Ask the user (if not already given) for either:

- **A seed color** — a hex value (`#RRGGBB`) or a plain color description
  you resolve to one, or
- **An image** — a local file path. Material Theme Builder can extract a
  representative seed color straight from an uploaded image (its own
  "Image" source-color option), so don't hand-pick a color from the image
  yourself — let the tool do it, that's the point of offering this input.

Also ask (or use a sensible default — "Tonal Spot", M3's standard variant)
which **variant/style** to generate if the user hasn't said — Material
Theme Builder's variant dropdown includes options like Tonal Spot, Vibrant,
Expressive, Neutral, etc.; if the project's existing theme already names
one (e.g. `PaletteStyle.TonalSpot`), match it by default unless told
otherwise.

## Step 3: Generate the scheme with Material Theme Builder

Use the `claude-in-chrome` skill's browser tools (load it first if not
already available). This tool's UI is a heavy animated single-page app —
give it a few seconds after navigating before your first screenshot/find
call, and don't loop retrying the same failing action more than 2-3 times;
if the page genuinely won't respond, stop and tell the user rather than
hammering it.

1. Navigate to `https://material-foundation.github.io/material-theme-builder/`.
2. Set the source color:
   - **Hex seed**: open the primary/source color picker and enter the hex
     value directly.
   - **Image**: use the tool's image-upload source-color option and upload
     the given file; let it pick the seed color from the image.
3. Set the variant/style if it differs from the tool's default, via its
   variant selector.
4. Open the **Export** panel and select the **Compose** (Jetpack
   Compose/Kotlin) export target — this format emits ready-to-use
   `lightColorScheme(...)`/`darkColorScheme(...)` Kotlin code naming every
   role explicitly, which is exactly what you need for Step 4.
5. Copy the exported Kotlin code (or read it directly off the page via
   `get_page_text`/`read_page` if a copy-to-clipboard action isn't
   readable back). If the Compose export option isn't available for some
   reason, fall back to reading each role's hex value off the tool's color
   role list/swatches (`read_page`/`zoom` screenshots on the swatch
   labels) for both light and dark schemes — every M3 `ColorScheme`
   constructor role (`primary`, `onPrimary`, `primaryContainer`,
   `onPrimaryContainer`, `secondary`, `onSecondary`, `secondaryContainer`,
   `onSecondaryContainer`, `tertiary`, `onTertiary`, `tertiaryContainer`,
   `onTertiaryContainer`, `error`, `onError`, `errorContainer`,
   `onErrorContainer`, `background`, `onBackground`, `surface`,
   `onSurface`, `surfaceVariant`, `onSurfaceVariant`, `outline`,
   `outlineVariant`, `scrim`, `inverseSurface`, `inverseOnSurface`,
   `inversePrimary`, `surfaceDim`, `surfaceBright`,
   `surfaceContainerLowest`, `surfaceContainerLow`, `surfaceContainer`,
   `surfaceContainerHigh`, `surfaceContainerHighest`) needs a value for
   both light and dark to build this by hand.
6. Close any tab you opened for this once you're done with it (see the
   `claude-in-chrome` skill's tab-cleanup guidance).

## Step 4: Apply it to the project

- **Stock M3 builders**: replace the existing
  `lightColorScheme()`/`darkColorScheme()` call sites' arguments with the
  full generated role list from Step 3 (`Color(0xFF......)` per role,
  matching the project's existing import/formatting style). Leave
  everything else in the file (typography, shapes, the `@Composable`
  theme wrapper) untouched.
- **Seed-generator library**: replace just the seed color constant (and
  the `style`/variant argument, if it changed) — leave the
  `dynamicColorScheme(...)` call itself alone.
- If the project's design-system pattern doc names an approval gate for
  changing theme values (see Step 1), that gate is about *hardcoding a
  literal outside the theme file* — replacing the seed/generated values
  *inside* the theme file itself, which is exactly this skill's job, does
  not need that approval. It's still worth a heads-up to the user about
  what changed.

## Step 5: Report

Show the user the new seed color/image used, the variant/style, which
file(s) changed, and — if the project has a running dev server workflow
gated behind manual approval (check `CLAUDE.md`) — remind them a visual
check needs that same approval before you'd launch it yourself. Don't
commit anything unless asked.
