---
name: Modern Heritage
colors:
  surface: '#131313'
  surface-dim: '#131313'
  surface-bright: '#393939'
  surface-container-lowest: '#0e0e0e'
  surface-container-low: '#1c1b1b'
  surface-container: '#20201f'
  surface-container-high: '#2a2a2a'
  surface-container-highest: '#353535'
  on-surface: '#e5e2e1'
  on-surface-variant: '#c0c9c0'
  inverse-surface: '#e5e2e1'
  inverse-on-surface: '#313030'
  outline: '#8a938b'
  outline-variant: '#404942'
  surface-tint: '#98d4ac'
  primary: '#98d4ac'
  on-primary: '#00391f'
  primary-container: '#004225'
  on-primary-container: '#75af89'
  inverse-primary: '#316948'
  secondary: '#c6c6c6'
  on-secondary: '#2f3131'
  secondary-container: '#484949'
  on-secondary-container: '#b8b8b8'
  tertiary: '#e3c0a6'
  on-tertiary: '#412c1a'
  tertiary-container: '#4b3422'
  on-tertiary-container: '#bd9c84'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#b4f0c7'
  primary-fixed-dim: '#98d4ac'
  on-primary-fixed: '#002110'
  on-primary-fixed-variant: '#165132'
  secondary-fixed: '#e3e2e2'
  secondary-fixed-dim: '#c6c6c6'
  on-secondary-fixed: '#1a1c1c'
  on-secondary-fixed-variant: '#464747'
  tertiary-fixed: '#ffdcc3'
  tertiary-fixed-dim: '#e3c0a6'
  on-tertiary-fixed: '#2a1707'
  on-tertiary-fixed-variant: '#5a422e'
  background: '#131313'
  on-background: '#e5e2e1'
  surface-variant: '#353535'
typography:
  display-lg:
    fontFamily: Archivo Narrow
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 52px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Archivo Narrow
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Archivo Narrow
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
  title-md:
    fontFamily: Archivo Narrow
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: 0.05em
  body-lg:
    fontFamily: Hanken Grotesk
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Hanken Grotesk
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  data-mono:
    fontFamily: JetBrains Mono
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.02em
  label-caps:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.1em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 12px
  md: 24px
  lg: 48px
  xl: 80px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 64px
---

## Brand & Style
The design system is built upon the "Modern Heritage" philosophy—a fusion of mid-century industrial engineering and contemporary premium digital craftsmanship. It evokes the tactile sensation of cold steel, the grit of a long-distance tour, and the precision of a mechanical watch.

The aesthetic leans into **Tactile Minimalism** with a **Brutalist** structural foundation. It avoids ephemeral trends in favor of timeless, heavy-duty UI elements. Interfaces should feel "built, not rendered," utilizing subtle metallic gradients, high-contrast borders, and a sense of physical weight. The emotional response is one of reliability, authenticity, and rugged sophistication.

## Colors
The palette is rooted in the "British Racing Green" heritage, serving as the primary brand anchor. 

- **Primary (British Racing Green):** Used for key brand moments, primary actions, and success states.
- **Secondary (Chrome/Silver):** Applied to interactive strokes, toggles, and iconography to simulate metallic hardware.
- **Tertiary (Desert Sand):** Used for highlighting technical data, warnings, or providing contrast against dark backgrounds.
- **Neutral (Deep Charcoal):** The foundation for all background surfaces, providing a low-glare, "night-ride" aesthetic.

Color is applied with intent: use Chrome for physical interaction points and Desert Sand for legibility in information-dense layouts.

## Typography
Typography reflects the contrast between vintage badging and modern instrumentation.

- **Headlines:** Uses a condensed, bold sans-serif to mimic stencil-cut metal plates and tank badges. These should always be uppercase to command authority.
- **Body:** A clean, contemporary grotesque provides maximum readability for long-form content.
- **Technical Data:** A monospaced font is used for all numerical values, specifications, and "engine-room" details, reinforcing the precision engineering aspect of the brand.

## Layout & Spacing
The layout follows a **Rigid Grid** philosophy, reminiscent of technical blueprints. 

- **Desktop:** 12-column grid with generous 24px gutters. Content is often contained within "frames" or "panels" to suggest modular assembly.
- **Mobile:** 4-column grid with tight 16px margins to maximize screen real estate for technical data.
- **Rhythm:** An 8px base unit drives all padding and margin decisions. Use heavy top-spacing (`xl`) for display sections to allow the "Modern Heritage" imagery to breathe.

## Elevation & Depth
This design system rejects floating "cloud-like" shadows in favor of **Mechanical Layering**.

- **Stacked Tiers:** Surfaces use varying shades of Charcoal to indicate depth. Backgrounds are the darkest, while interactive panels are slightly lighter.
- **Inverted Shadows:** Instead of shadows that lift elements *off* the page, use inner shadows and "stamped" effects to make inputs feel recessed into the dashboard.
- **Beveled Edges:** Use 1px Chrome (#C0C0C0) borders with low opacity (20-30%) on the top and left edges of components to simulate light catching on a metal edge.

## Shapes
The shape language is primarily **Industrial and Geometric**.

- **Outer Containers:** Use "Soft" (0.25rem) corner radii to suggest machined metal rather than sharp, dangerous edges.
- **Functional Elements:** Circular shapes are reserved strictly for gauges, dials, and primary action toggles, mimicking a motorcycle's instrument cluster.
- **Connectors:** Use 45-degree chamfered corners for decorative accents or "badge" style containers to reinforce the vintage mechanical aesthetic.

## Components
- **Buttons:** Designed to look like physical toggles. Primary buttons use a British Racing Green fill with a subtle vertical gradient. Secondary buttons use a "knurled" stroke pattern (a repeating 2px diagonal line pattern) on the border to suggest grip.
- **Gauges:** Instead of standard progress bars, use circular rings with Desert Sand indicators for data like "Fuel," "Power," or "Progress."
- **Toggles:** Modelled after handlebar kill-switches. High physical contrast between 'On' (Green) and 'Off' (Charcoal).
- **Cards:** Heavy-duty panels with 1px Chrome borders. Headers should be separated from the body by a solid horizontal rule, mimicking a nameplate.
- **Input Fields:** Recessed appearance with `data-mono` typography. Labels are always `label-caps` placed outside the field, similar to stamped instructions on a machine part.
- **Chips:** Small, pill-shaped markers with high-contrast borders and mono-type, used for technical specs (e.g., "350CC", "ABS").