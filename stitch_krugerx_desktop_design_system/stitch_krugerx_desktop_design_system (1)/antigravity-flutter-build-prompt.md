# Flutter Frontend Build — Antigravity Agent Prompt

## Role
You are a senior Flutter engineer building a production-grade web frontend
from a finalized design export. Prioritize correctness, consistency, and
fidelity to the source over speed. If any instruction below is ambiguous,
default to the more rigorous interpretation rather than the faster one.

## Source of Truth
Folder: `stitch_krugerx_desktop_design_system`
Contents: HTML/CSS exported from Stitch (desktop/web mode)
Screens included: Dashboard, Login, Settings

Treat the HTML/CSS as ground truth for all visual values — colors, spacing,
typography, border radius, shadows. Do not approximate or "close enough"
any value. If a value is ambiguous or missing in the source, flag it in
your final summary rather than guessing silently.

---

## Phase 1 — Extract the Design System (do this before writing any screen)

Parse all HTML/CSS files and produce a single centralized design system:

- **Color palette**: primary, secondary, accent, background, surface,
  text (primary/secondary/disabled), error, success, warning — exact hex
  values, mapped into a Flutter `ColorScheme`
- **Typography scale**: font family, weights, and sizes for all heading
  levels, body text, labels, buttons, captions — mapped into `TextTheme`
- **Spacing/sizing scale**: every padding/margin/gap value used across the
  source files, normalized into a consistent spacing constant set
  (e.g. 4/8/12/16/24/32) rather than hardcoded magic numbers per screen
- **Shape system**: border radius values, elevation/shadow values
- **Shared components**: identify every component reused across screens
  (buttons, text fields, cards, nav items, dropdowns, toggles, avatars,
  badges, dividers) and build each as a standalone reusable widget

Output: a `theme/` directory (colors, text styles, spacing constants) and
a `widgets/` directory (shared components). No screen should define colors,
font sizes, or spacing inline — everything pulls from these two sources.

---

## Phase 2 — Build Every Screen Completely

For **Login**, **Dashboard**, and **Settings**:

- Match layout structure, spacing, colors, and typography exactly against
  the HTML/CSS — verify against actual source values, not visual memory
- Convert HTML structure to semantically correct Flutter widgets
  (`Row`/`Column`/`Stack`/`Wrap` as appropriate) — do not wrap raw HTML in
  a WebView or approximate with a single generic layout
- Include every element present in the source: headers, nav/sidebar,
  footer, icons, labels, placeholder/helper text, dividers — nothing
  cosmetic gets dropped for convenience
- Preserve exact content hierarchy and reading order from the HTML DOM

---

## Phase 3 — States Not Present in Static Export

Stitch exports one static state per element. You must explicitly design
and implement the states it doesn't show:

- **Interactive states**: hover, focus, pressed, disabled — for every
  button, input, link, and clickable card
- **Loading states**: skeleton loaders or spinners for the dashboard's
  data-driven regions
- **Empty states**: what the dashboard/settings look like with no data
- **Error states**: invalid login credentials, failed form submission,
  network error on dashboard load
- **Validation feedback**: real-time or on-submit validation for login
  and settings form fields, with clear inline error messaging

Do not skip this phase — a frontend that only handles the "happy path"
shown in the static design is incomplete.

---

## Phase 4 — Navigation & Routing

- Implement routing with `go_router`
- Flow: Login → Dashboard (default authenticated route) → Settings
  (accessible from Dashboard nav)
- Guard authenticated routes — Settings/Dashboard should not be reachable
  without a valid (or mocked) authenticated state
- If a persistent nav shell (sidebar/topbar) appears across screens in the
  source, implement it once as a shared shell, not duplicated per screen

---

## Phase 5 — Responsiveness

This is a desktop-first design — do not assume it will look correct at
other widths without explicit work.

- Use `LayoutBuilder`/`MediaQuery` to define breakpoints (mobile, tablet,
  desktop)
- Sidebar/nav should collapse or transform appropriately below desktop
  width (e.g. to a drawer or bottom nav) rather than just shrinking
- Text and spacing should scale sensibly, not just clip or overflow

---

## Phase 6 — Motion & Interaction

- Page transitions between routes (fade or slide — match the tone of the
  design, not a default platform transition)
- Implicit animations (`AnimatedContainer`, `AnimatedOpacity`,
  `AnimatedSwitcher`) for state changes — no instant/jarring UI jumps
- Smooth scroll physics on the dashboard
- Subtle micro-interactions on buttons/cards (scale or elevation change
  on press) — restrained, not decorative for its own sake

---

## Phase 7 — Architecture & State Management

- **State management: Riverpod** (with code generation via `@riverpod`
  annotations where practical) — use `AsyncValue` for all async/API-backed
  state (login submission, dashboard data) rather than manual
  loading/error booleans
- Clean architecture: separate `presentation/`, `domain/`, and `data/`
  layers — screens should not contain business logic or direct data
  fetching
- No hardcoded strings, colors, or spacing anywhere in screen code —
  everything resolves through the theme system from Phase 1
- Support light and dark mode using the same design tokens (derive dark
  variants systematically, don't hand-pick arbitrary dark colors)

---

## Constraints — Do Not

- Do not invent new colors, fonts, or spacing values not derivable from
  the source or a sensible extension of its scale
- Do not skip states, screens, or elements to save time — flag anything
  you're deferring, don't silently omit it
- Do not use GetX or Provider — Riverpod only
- Do not hardcode text/values inline "temporarily" — build it correctly
  the first time

---

## Definition of Done

Before reporting completion:

1. Run the app and open each screen in the integrated browser
2. Compare each screen side-by-side against its source HTML file
3. Produce a short discrepancy list: anything that doesn't match
   (color, spacing, missing element, missing state) — even minor
4. Confirm light/dark mode both render correctly on all three screens
5. Confirm the app is navigable end-to-end: Login → Dashboard → Settings
   and back, including error/loading states

Report the discrepancy list explicitly at the end, even if empty.
