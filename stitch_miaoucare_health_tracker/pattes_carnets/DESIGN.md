---
name: Pattes & Carnets
colors:
  surface: '#fbf9f4'
  surface-dim: '#dcdad5'
  surface-bright: '#fbf9f4'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f6f3ee'
  surface-container: '#f0eee9'
  surface-container-high: '#eae8e3'
  surface-container-highest: '#e4e2dd'
  on-surface: '#1b1c19'
  on-surface-variant: '#45483f'
  inverse-surface: '#30312d'
  inverse-on-surface: '#f3f0eb'
  outline: '#76786e'
  outline-variant: '#c6c8bb'
  surface-tint: '#566342'
  primary: '#566342'
  on-primary: '#ffffff'
  primary-container: '#a3b18a'
  on-primary-container: '#384425'
  inverse-primary: '#becca3'
  secondary: '#356668'
  on-secondary: '#ffffff'
  secondary-container: '#b9ecee'
  on-secondary-container: '#3c6c6e'
  tertiary: '#74556a'
  on-tertiary: '#ffffff'
  tertiary-container: '#c6a1b9'
  on-tertiary-container: '#53374b'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dae8be'
  primary-fixed-dim: '#becca3'
  on-primary-fixed: '#141f05'
  on-primary-fixed-variant: '#3f4b2c'
  secondary-fixed: '#b9ecee'
  secondary-fixed-dim: '#9ecfd1'
  on-secondary-fixed: '#002021'
  on-secondary-fixed-variant: '#1a4e50'
  tertiary-fixed: '#ffd7f0'
  tertiary-fixed-dim: '#e2bbd4'
  on-tertiary-fixed: '#2b1325'
  on-tertiary-fixed-variant: '#5b3e52'
  background: '#fbf9f4'
  on-background: '#1b1c19'
  surface-variant: '#e4e2dd'
typography:
  display-lg:
    fontFamily: Quicksand
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-md:
    fontFamily: Quicksand
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  title-sm:
    fontFamily: Quicksand
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Nunito Sans
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 26px
  body-md:
    fontFamily: Nunito Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Nunito Sans
    fontSize: 14px
    fontWeight: '700'
    lineHeight: 20px
    letterSpacing: 0.5px
  label-sm:
    fontFamily: Nunito Sans
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 12px
  md: 24px
  lg: 32px
  xl: 48px
  edge_margin: 20px
  gutter: 16px
---

## Brand & Style

This design system is built on the principles of **Organic Minimalism**. It aims to evoke a sense of calm, reliability, and warmth, catering to pet owners who view their cats as family members. The visual language balances professional veterinary tracking with a whimsical, approachable aesthetic. 

The style utilizes generous whitespace and a "soft-touch" interface, moving away from clinical rigidity toward a nurturing, domestic feel. By combining high-quality rounded typography with a palette inspired by nature, the design system ensures that the complexity of pet health management feels light and manageable.

## Colors

The color strategy for this design system relies on low-contrast, earthy tones to reduce cognitive load. 
- **Sage Green** serves as the primary anchor, representing growth and health.
- **Soft Blue** is used for secondary actions and interactive elements that require distinction without being jarring.
- **Beige and Cream** create a layered background experience; the darker beige is used for the base scaffold, while the lighter cream is used for card surfaces to create natural "lift."
- **Terracotta and Ochre** are reserved strictly for health status alerts (upcoming and late tasks), ensuring they stand out against the soft primary palette.

## Typography

This design system utilizes a dual-font approach to maximize both friendliness and legibility. **Quicksand** is used for all display and headline levels; its rounded terminals and geometric bones provide the "feline" softness required for the brand. 

For longer passages of text and functional labels, **Nunito Sans** is employed. It maintains the rounded aesthetic of the headlines but offers better spacing and character distinctness at smaller sizes, ensuring that medical notes and schedules are easy to read at a glance.

## Layout & Spacing

The layout follows a **fluid grid model** optimized for mobile viewports. A 4-column structure is used with a 20px outer margin to provide "breathing room" around the content. 

Spacing is governed by an 8px rhythmic scale. Generous vertical padding (24px to 32px) is encouraged between card elements to maintain the minimalist feel and prevent the UI from appearing cluttered. Content should be centered within cards with consistent internal padding of 20px.

## Elevation & Depth

Hierarchy is achieved through **ambient shadows** and tonal layering rather than high-contrast borders. 
- **Level 0:** The base background (#F5EBE0).
- **Level 1:** Primary cards (#FEFAE0) with a very soft, diffused shadow (Box-shadow: 0 4px 20px rgba(163, 177, 138, 0.12)). The shadow color is slightly tinted with the primary sage to keep the palette harmonious.
- **Level 2:** Modals and active floating action buttons, using a more pronounced but still soft shadow (Box-shadow: 0 8px 30px rgba(0, 0, 0, 0.08)).

This system avoids harsh blacks in shadows, preferring deep muted tones to maintain the "soft" brand promise.

## Shapes

The shape language is dominated by large, friendly radii. 
- **Cards and Containers:** Use the `rounded-lg` (16px) or `rounded-xl` (24px) setting to create a "pillow-like" appearance.
- **Interactive Elements:** Buttons and tags should utilize a pill-shape (fully rounded) to invite interaction.
- **Iconography:** Icons should feature rounded caps and corners. Where possible, incorporate subtle feline motifs (e.g., a tab indicator shaped like a cat's ear or a progress bar ending in a paw print).

## Components

### Buttons
Primary buttons are pill-shaped, using the Sage Green background with white or deep-sage text. Secondary buttons use the Soft Blue with a ghost-border style or a light blue tint. High-intensity actions (like deleting a record) use the Terracotta color.

### Cards
Cards are the core of this design system. They must use the Cream (#FEFAE0) surface color on the Beige background. They should always feature the standard soft shadow. For health records, cards include a left-hand color strip (Green, Orange, or Red) to indicate status.

### Health Status Indicators
Health status is represented by a "Status Badge" – a small, rounded pill with a low-opacity background of the status color and a high-opacity text/icon of the same color. 
- **Up-to-date:** Sage.
- **Upcoming:** Ochre/Orange.
- **Late:** Terracotta.

### Inputs & Form Fields
Input fields are styled with a soft cream background and a 1px border in a darker beige. On focus, the border transitions to Sage Green. Labels are always placed above the field in Nunito Sans Bold.

### Feline Details
Use custom iconography for navigation: a paw for "Profile," a bell with ears for "Notifications," and a stylized cat-face for "Home." Tab bar active states should be indicated by a soft sage dot or a "whisker" underline.