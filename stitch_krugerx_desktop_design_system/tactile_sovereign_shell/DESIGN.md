---
name: Tactile Sovereign Shell
colors:
  surface: '#17111e'
  surface-dim: '#17111e'
  surface-bright: '#3e3645'
  surface-container-lowest: '#110c18'
  surface-container-low: '#1f1926'
  surface-container: '#231d2b'
  surface-container-high: '#2e2735'
  surface-container-highest: '#393241'
  on-surface: '#eadef2'
  on-surface-variant: '#dbc2ad'
  inverse-surface: '#eadef2'
  inverse-on-surface: '#352e3c'
  outline: '#a38d7a'
  outline-variant: '#554434'
  surface-tint: '#ffb86f'
  primary: '#ffc082'
  on-primary: '#4a2800'
  primary-container: '#ff9900'
  on-primary-container: '#653a00'
  inverse-primary: '#8a5100'
  secondary: '#7dffa2'
  on-secondary: '#003918'
  secondary-container: '#05e777'
  on-secondary-container: '#00622e'
  tertiary: '#dbc2ff'
  on-tertiary: '#40127c'
  tertiary-container: '#c5a0ff'
  on-tertiary-container: '#552c91'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#ffdcbd'
  primary-fixed-dim: '#ffb86f'
  on-primary-fixed: '#2c1600'
  on-primary-fixed-variant: '#693c00'
  secondary-fixed: '#62ff96'
  secondary-fixed-dim: '#00e475'
  on-secondary-fixed: '#00210b'
  on-secondary-fixed-variant: '#005226'
  tertiary-fixed: '#ecdcff'
  tertiary-fixed-dim: '#d6baff'
  on-tertiary-fixed: '#280057'
  on-tertiary-fixed-variant: '#582f94'
  background: '#17111e'
  on-background: '#eadef2'
  surface-variant: '#393241'
typography:
  display-lg:
    fontFamily: Epilogue
    fontSize: 48px
    fontWeight: '900'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-xl:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  title-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: '0'
  body-base:
    fontFamily: Inter
    fontSize: 15px
    fontWeight: '400'
    lineHeight: 22px
    letterSpacing: '0'
  body-medium:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: '0'
  code-mono:
    fontFamily: JetBrains Mono
    fontSize: 13px
    fontWeight: '500'
    lineHeight: 18px
    letterSpacing: -0.01em
  label-caps:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '700'
    lineHeight: 14px
    letterSpacing: 0.12em
  status-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  xs: 8px
  sm: 12px
  md: 16px
  lg: 24px
  xl: 32px
  sidebar-rail: 60px
  sidebar-expanded: 240px
  copilot-panel: 280px
  titlebar-height: 44px
  min-target: 40px
---

## Brand & Style

The design system embodies a "Mystical Iron" aesthetic—an industrial, power-user interface that blends deep cosmic blacks with glowing eldritch accents. It is engineered for high-performance desktop environments, prioritizing speed, privacy, and contextual intelligence.

The visual language combines **Minimalism** in layout with **Glassmorphism** and **Tactile** elements. High-contrast surfaces minimize eye fatigue, while precision-machined frosted glass layers and multi-stop hairline gradients create a sense of depth and technological supremacy. Interactions are deliberate, featuring golden magnetic hover halos and pulsing emerald intelligence nodes, ensuring the interface feels responsive and premium.

## Colors

This design system utilizes a tiered dark-mode palette to establish structural hierarchy without relying on heavy borders.

- **Primary Foundation:** The "Void" (`#05020B`) serves as the root backdrop. Surfaces elevate from Canvas (`#0E0E12`) to Chrome (`#1A1A1F`), creating clear distinction between workspace areas, sidebars, and tab tracks.
- **Accents:** **Eldritch Gold** is the core interactive color, used for primary actions and active states. **Time Stone Green (Emerald)** is reserved for AI features and "Online" status indicators.
- **Glassmorphism:** Translucent layers use a `20px` backdrop blur with a subtle `rgba(20, 15, 35, 0.40)` base to maintain legibility over complex backgrounds.
- **Hairlines:** 1px borders using low-opacity whites define functional zones with surgical precision.

## Typography

Typography is systematic and utilitarian, utilizing **Inter** for most UI elements to ensure maximum legibility across pixel densities.

- **Display:** Used exclusively for hero statements or empty states, utilizing **Epilogue** (substituting for decorative brand fonts) to provide a distinctive, bold character.
- **Headlines:** Feature tight line-heights and negative tracking to reinforce the industrial, compact feel.
- **Technical Readouts:** The Omnibar and code snippets use **JetBrains Mono**, providing a clear distinction between user interface text and machine/system data.
- **Micro-Labels:** Use uppercase styling with increased letter-spacing (`0.12em`) for high-contrast metadata tagging.

## Layout & Spacing

The system follows a **Fixed-Fluid Hybrid** shell model optimized for resizable desktop windows.

- **Structural Shell:** A fixed 44px titlebar contains window controls and tabs. Navigation is handled via a 60px vertical sidebar rail that can expand to 240px. The right side features a collapsible 280px AI Copilot panel.
- **The Viewport:** The central workspace is fluid but enforces a `max-width: 1400px` for content readability on ultrawide displays.
- **Rhythm:** A 4px base unit governs all spacing. Internal card padding is typically 24px, while dense data views scale down to 16px. 
- **Accessible Targets:** Despite the "compact" industrial look, all interactive elements maintain a minimum **40px click target** to support both precise mouse movement and touch-enabled desktop hardware.

## Elevation & Depth

Depth is established through **Tonal Layering** and **Glassmorphism** rather than traditional soft shadows.

- **Layering:** Backgrounds are the darkest (`#05020B`), while active panels and interactive containers use lighter surface tones (`#141418` to `#1A1A1F`).
- **Glass Effects:** Modals and floating action bars use "Frosted Glass"—a semi-transparent layer with a `20px` backdrop blur and a `1px` high-legibility outline.
- **Interactive Depth:** On hover, cards and buttons use a `translateY(-2px)` or `(-4px)` shift combined with an **Ambient Glow** (e.g., a subtle 15px-30px box-shadow tinted with the accent color) to simulate a magnetic pull.

## Shapes

The shape language reflects "Modern Industrial." 

- **Standard Elements:** Buttons, input fields, and sidebar icons use a 0.5rem (`rounded-md`) radius for a balanced, professional feel.
- **Containers:** Large cards and glass modals utilize 1rem to 1.5rem (`rounded-lg` / `rounded-xl`) to soften the high-contrast industrial aesthetic and signal "contained" information.
- **Specialty:** Tab tops use a top-only 8px radius to integrate cleanly with the titlebar rail. Search bars and primary pills may use a fully rounded (pill-shaped) geometry to denote their distinct interactive role.

## Components

- **Buttons:**
    - **Primary:** High-energy `135deg` gradient from Eldritch Orange to Gold. Uppercase text with 1px tracking.
    - **Secondary/Ghost:** `rgba(255, 255, 255, 0.04)` fill with a 1px `outline-low` border. 
- **Unified Omnibar:** 36px height, `JetBrains Mono` text, with a persistent security shield icon on the left and an AI trigger on the right.
- **Tabs:**
    - **Active:** Matches the canvas color (`#0E0E12`) with a 2px top border in Eldritch Gold.
    - **Inactive:** Matches the chrome color (`#1A1A1F`) with muted text.
- **Navigation Rail:** 60px wide. Icons are centered in 40x40px hit zones. Active states feature a 15% opacity gold background and a solid gold vertical indicator.
- **AI Copilot Bubbles:** 
    - AI responses use a faint emerald tint (`#00E676` at 7% opacity).
    - User prompts use a faint gold tint (`#FF9900` at 8% opacity).
- **Cards:** 3D glass surfaces with hairline gradients that fade from `rgba(255, 255, 255, 0.15)` at the top to `0.02` at the bottom.