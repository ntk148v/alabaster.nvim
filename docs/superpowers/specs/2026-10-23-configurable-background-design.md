# Configurable background for all Alabaster variants

Date: 2026-10-23

## Goal

Let users override the background color of `alabaster`, `alabaster-bg`, and
`alabaster-mono` without adding another variant. The background drives the
neutral UI surfaces so popup menus, statuslines, selections, and folds keep
contrast with the editor background.

## API

```vim
let g:alabaster_background = "#FFFCF0"
```

- Accepts `#RRGGBB` or `RRGGBB`, case-insensitive.
- Unset or empty keeps the existing built-in background and produces exactly
  the same highlights as before.
- Invalid values emit one `vim.notify` warning at `WARN` level and fall back to
  the built-in background.

The option is read when a scheme loads, so it must be set before
`:colorscheme`.

## Behavior

### `alabaster`

The luminance of the custom background selects the dark or light palette, and
`vim.o.background` is set to match. Without the option, the existing
`vim.o.background` behavior is unchanged.

Neutral surfaces are re-derived from the custom background:

| Surface | Light background | Dark background |
| --- | --- | --- |
| popup, cursorline, subtle overlay, float | shade 4% | tint 6% |
| statusline, tabs, folds | shade 8% | tint 9% |
| visual selection | shade 12% | tint 14% |
| menu selection | shade 16% | tint 18% |
| borders, end-of-buffer | shade 20% | tint 22% |
| non-text | shade 55% | tint 45% |
| line numbers | shade 48% | tint 40% |
| scrollbar track | shade 28% | tint 12% |
| scrollbar thumb | shade 62% | tint 40% |

"Shade" mixes toward black; "tint" mixes toward white. Text and accent colors
are left alone.

### `alabaster-bg`

The custom background replaces the normal background, and neutral surfaces are
derived with the same rules. Text flips to `#F7F7F7` when the custom background
is dark. The variant's colored block backgrounds (comments, strings,
definitions, errors, menus, search) stay light and keep black text.

### `alabaster-mono`

The custom background replaces white, and the two grey surfaces are derived
from it. Text flips to `#F7F7F7` when the custom background is dark. The cyan
cursor and search colors keep black text.

## Implementation

- New `lua/alabaster/color.lua`: `normalize`, `mix`, `shade`, `tint`,
  `luminance`, `is_dark`.
- `lua/alabaster/init.lua`: `custom_background()` validates and caches the
  warning; `retint()` rewrites neutral UI groups for `alabaster`; both other
  variants derive their local surface colors and text color directly.

## Verification

- With the option unset, the full highlight table for all three variants is
  identical to the previous commit.
- `#FFFCF0` gives warm paper surfaces and dark text.
- `#100F0F` gives light text and lighter surfaces.
- An invalid value warns once and falls back.
- `g:alabaster_floatborder` and `g:alabaster_dim_comments` still work.
