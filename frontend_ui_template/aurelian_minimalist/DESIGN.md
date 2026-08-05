---
name: Aurelian Minimalist
colors:
  surface: '#fbf9f8'
  surface-dim: '#dbdad9'
  surface-bright: '#fbf9f8'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f5f3f3'
  surface-container: '#efeded'
  surface-container-high: '#e9e8e7'
  surface-container-highest: '#e4e2e2'
  on-surface: '#1b1c1c'
  on-surface-variant: '#444748'
  inverse-surface: '#303031'
  inverse-on-surface: '#f2f0f0'
  outline: '#747878'
  outline-variant: '#c4c7c7'
  surface-tint: '#5f5e5e'
  primary: '#000000'
  on-primary: '#ffffff'
  primary-container: '#1c1b1b'
  on-primary-container: '#858383'
  inverse-primary: '#c8c6c5'
  secondary: '#775a19'
  on-secondary: '#ffffff'
  secondary-container: '#fed488'
  on-secondary-container: '#785a1a'
  tertiary: '#000000'
  on-tertiary: '#ffffff'
  tertiary-container: '#1b1c19'
  on-tertiary-container: '#848480'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e5e2e1'
  primary-fixed-dim: '#c8c6c5'
  on-primary-fixed: '#1c1b1b'
  on-primary-fixed-variant: '#474646'
  secondary-fixed: '#ffdea5'
  secondary-fixed-dim: '#e9c176'
  on-secondary-fixed: '#261900'
  on-secondary-fixed-variant: '#5d4201'
  tertiary-fixed: '#e4e2dd'
  tertiary-fixed-dim: '#c8c6c2'
  on-tertiary-fixed: '#1b1c19'
  on-tertiary-fixed-variant: '#474744'
  background: '#fbf9f8'
  on-background: '#1b1c1c'
  surface-variant: '#e4e2e2'
typography:
  display-lg:
    fontFamily: Libre Caslon Text
    fontSize: 48px
    fontWeight: '400'
    lineHeight: 56px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Libre Caslon Text
    fontSize: 32px
    fontWeight: '400'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Libre Caslon Text
    fontSize: 32px
    fontWeight: '400'
    lineHeight: 40px
  headline-sm:
    fontFamily: Libre Caslon Text
    fontSize: 24px
    fontWeight: '400'
    lineHeight: 32px
  title-lg:
    fontFamily: Hanken Grotesk
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: 0.01em
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
  label-md:
    fontFamily: Hanken Grotesk
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.05em
  label-sm:
    fontFamily: Hanken Grotesk
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.08em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  unit: 8px
  container-max: 1200px
  gutter: 32px
  margin-desktop: 64px
  margin-mobile: 20px
  stack-lg: 48px
  stack-md: 24px
  stack-sm: 12px
---

## Brand & Style
This design system embodies a "Quiet Luxury" aesthetic, moving away from tech-centric vibrancy toward a high-end, editorial feel. The brand personality is authoritative yet welcoming, targeting a sophisticated audience that values clarity, depth, and intentionality.

The design style is a hybrid of **Minimalism** and **Modern Corporate**, utilizing expansive whitespace and a restrained color palette to create a sense of calm and exclusivity. Visual interest is generated through precise typographic hierarchies and subtle, high-quality textures rather than aggressive UI patterns. The emotional response should be one of stability, premium quality, and intellectual focus.

## Colors
The palette is rooted in a "Champagne and Charcoal" motif to evoke a sense of heritage and premium craft.

- **Primary (Deep Charcoal):** Used for primary text, iconography, and high-emphasis backgrounds. It provides the grounding weight for the interface.
- **Secondary (Muted Gold):** Reserved for subtle accents, active states, and call-to-action highlights. It should be used sparingly to maintain its "precious" quality.
- **Tertiary (Soft Cream):** The foundational surface color. It reduces eye strain compared to pure white and adds a warm, paper-like quality to the UI.
- **Neutral (Stone Gray):** Used for secondary text, borders, and disabled states to maintain a low-contrast, harmonious environment.

## Typography
The typography strategy pairings a traditional, high-contrast serif with a clean, contemporary grotesque. 

**Libre Caslon Text** is used for headlines to convey editorial authority and timelessness. For larger display sizes, slight negative letter-spacing is applied to enhance the "locked-in" premium feel. 

**Hanken Grotesk** handles all functional and body copy. It is chosen for its sharp terminals and modern clarity, providing a technical counterpoint to the classic serif. Labels and small metadata should utilize increased letter-spacing and uppercase styling to mimic high-end fashion or architectural signage.

## Layout & Spacing
The layout follows a **Fixed Grid** philosophy for desktop to maintain a controlled, gallery-like presentation. On mobile, it transitions to a fluid model with generous safe-area margins.

A "loose" spacing rhythm is critical for this design system. Rather than packing information, use `stack-lg` and `stack-md` to let elements breathe. Gutters are intentionally wide (32px) to prevent visual clutter. High-level sections should be separated by significant vertical whitespace to signal a change in topic or importance, reinforcing the premium, unhurried user experience.

## Elevation & Depth
Depth is communicated through **Tonal Layers** and **Low-Contrast Outlines** rather than heavy shadows. 

1.  **Level 0 (Base):** Soft Cream (#F9F7F2).
2.  **Level 1 (Cards/Surface):** Pure White (#FFFFFF) with a 1px solid border in a very faint neutral (#E5E5E5).
3.  **Level 2 (Interactive):** Elements that require focus use a single, highly diffused ambient shadow (Color: Primary, Opacity: 4%, Blur: 20px) to appear as if they are gently floating.

Avoid using shadows on buttons or inputs; instead, use subtle background color shifts (e.g., Cream to White) to indicate elevation or interactivity.

## Shapes
This design system utilizes **Soft** roundedness. Precision is key; large, "bubbly" curves are avoided in favor of subtle 0.25rem (4px) radii. This creates a geometric, architectural feel that feels more "designed" and less "default." 

Interactive components like buttons and input fields should strictly adhere to the `rounded-sm` or `rounded-md` tokens. Only user avatars or specific decorative icons may use circular masks.

## Components
- **Buttons:** Primary buttons feature a solid Charcoal background with White text. Secondary buttons use a Muted Gold border with Charcoal text. No heavy gradients; use flat fills.
- **Input Fields:** Use a "minimalist underline" or a 1px border on all sides. The background should be slightly lighter than the page background to indicate an "inset" area.
- **Cards:** Cards should have no visible shadow by default, relying on a 1px Stone Gray border. On hover, the border may transition to Muted Gold.
- **Chips/Tags:** Use the `label-sm` typographic style. Backgrounds should be a very pale version of the Gold accent or a light Gray.
- **Lists:** Items are separated by thin, hairline dividers. Increase vertical padding within list items to 16px-20px to maintain the airy aesthetic.
- **Navigation:** Top-level navigation should be centered with generous letter-spacing on menu items, using the `label-md` style.