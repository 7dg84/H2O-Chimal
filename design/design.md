---
name: H20 Chimal Design System
colors:
  surface: '#f8f9ff'
  surface-dim: '#cbdbf5'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e5eeff'
  surface-container-high: '#dce9ff'
  surface-container-highest: '#d3e4fe'
  on-surface: '#0b1c30'
  on-surface-variant: '#424752'
  inverse-surface: '#213145'
  inverse-on-surface: '#eaf1ff'
  outline: '#727784'
  outline-variant: '#c2c6d4'
  surface-tint: '#115cb9'
  primary: '#003f87'
  on-primary: '#ffffff'
  primary-container: '#0056b3'
  on-primary-container: '#bbd0ff'
  inverse-primary: '#acc7ff'
  secondary: '#00658d'
  on-secondary: '#ffffff'
  secondary-container: '#2dbcfe'
  on-secondary-container: '#004866'
  tertiary: '#004953'
  on-tertiary: '#ffffff'
  tertiary-container: '#00626f'
  on-tertiary-container: '#51e1fa'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d7e2ff'
  primary-fixed-dim: '#acc7ff'
  on-primary-fixed: '#001a40'
  on-primary-fixed-variant: '#004491'
  secondary-fixed: '#c6e7ff'
  secondary-fixed-dim: '#82cfff'
  on-secondary-fixed: '#001e2d'
  on-secondary-fixed-variant: '#004c6b'
  tertiary-fixed: '#a1efff'
  tertiary-fixed-dim: '#44d8f1'
  on-tertiary-fixed: '#001f25'
  on-tertiary-fixed-variant: '#004e59'
  background: '#f8f9ff'
  on-background: '#0b1c30'
  surface-variant: '#d3e4fe'
typography:
  h1:
    fontFamily: Public Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  h2:
    fontFamily: Public Sans
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  h3:
    fontFamily: Public Sans
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Public Sans
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Public Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-sm:
    fontFamily: Public Sans
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-xs:
    fontFamily: Public Sans
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
  base: 8px
  container-margin: 20px
  gutter: 16px
  stack-sm: 12px
  stack-md: 24px
  stack-lg: 40px
---

## Brand & Style
The brand personality is rooted in civic duty, reliability, and technical proficiency. This design system serves as a bridge between the municipality and its citizens, requiring an aesthetic that is both official and highly approachable. 

The chosen style is **Corporate / Modern**. It prioritizes clarity and efficiency over decorative elements. By utilizing a structured layout and a professional color palette, the UI communicates a sense of order and institutional stability. The goal is to evoke a feeling of "competence" and "transparency," ensuring users feel confident that their reports are being handled by a professional utility service.

## Colors
The color palette is derived directly from the institutional identity of the service. The **Primary Blue** is a deep, trustworthy navy that provides high contrast against light backgrounds, essential for official communications. The **Secondary Water Azure** and **Tertiary Teal** are used to provide visual relief and signify water-related actions or information.

For the semantic status indicators, high-saturation colors are used to ensure immediate recognition:
- **Red (Pending):** Signals urgency and a need for initial action.
- **Amber (In Review):** Indicates active attention and process.
- **Green (Resolved):** Communicates completion and success.
- **Blue (Received):** Confirms data entry without immediate status change.

Backgrounds utilize a "High-Contrast Light" approach, using pure white for content cards and very light cool-grays for the application canvas to reduce eye strain while maintaining a clean, sanitary look.

## Typography
This design system utilizes **Public Sans**, an open-source typeface designed for government and institutional interfaces. Its neutral, clean, and highly legible characteristics make it ideal for a municipal application where information density can be high.

The typography hierarchy is designed for "Scan-ability." Large headlines use a heavier weight and tighter letter-spacing to command attention, while body text maintains a generous line height to ensure accessibility for users of all ages. Small labels and metadata use increased letter-spacing and semi-bold weights to remain readable at reduced sizes, particularly in data-heavy reporting screens.

## Layout & Spacing
The layout follows a **Fluid Grid** model optimized for mobile devices. It utilizes a standard 8px baseline rhythm to ensure vertical harmony between components. 

- **Margins:** A consistent 20px side margin ensures content does not feel cramped on various screen widths.
- **Rhythm:** Components are stacked using "Large" spacing (40px) between major sections and "Medium" spacing (24px) between related groups. 
- **Forms:** Input fields and labels use "Small" spacing (12px) to keep the data entry flow tight and fast, supporting the goal of "Under 2 Minute" reporting.

## Elevation & Depth
To maintain a clean and professional look, this design system avoids heavy shadows. Instead, it employs **Tonal Layers** and **Low-Contrast Outlines**.

- **Surface 1 (Canvas):** Background Gray (#F8FAFC).
- **Surface 2 (Cards):** Pure White (#FFFFFF) with a 1px border in a subtle neutral tint (#E2E8F0).
- **Interactive Depth:** Only primary action buttons and active report cards receive a "Soft Ambient Shadow"—a very diffused, low-opacity (10%) shadow tinted with the primary blue color. This makes them appear to float slightly above the canvas, indicating interactability without cluttering the UI.

## Shapes
The shape language is **Rounded**, using a 0.5rem (8px) base radius. This level of rounding softens the institutional feel, making the application feel modern and "friendly" rather than bureaucratic and rigid. 

- **Standard Elements:** Buttons, Input Fields, and Cards use the 8px radius.
- **Large Elements:** Modal sheets and main navigation containers use 1.5rem (24px) for the top corners to create a distinct visual "nesting" effect.
- **Status Pills:** Utilize a full pill shape (100px radius) to distinguish them clearly from interactive buttons.

## Components

### Buttons
Primary buttons use the Deep Institutional Blue with white text. They are full-width in forms to provide a massive tap target. Secondary buttons use a light blue ghost style (outline only) to maintain hierarchy.

### Cards
Report cards are the heart of the management system. They feature a left-aligned colored strip corresponding to the semantic status (e.g., Red for Pending) and include the location, date, and a small thumbnail image of the reported leak.

### Input Fields
Inputs are structured for rapid entry. They feature a permanent top-aligned label (to avoid losing context while typing) and a subtle placeholder. Active states are indicated by a 2px Primary Blue border.

### Status Chips
Small, non-interactive indicators used in lists. They use a low-opacity background of the semantic color with high-contrast text of the same hue (e.g., Light green background with dark green text for 'Resolved').

### Map Interface
The map component uses a custom-styled tile set that desaturates the environment, allowing the municipal map pins (water drops or wrenches) to stand out prominently.

### Progress Stepper
For the report submission process, a horizontal stepper at the top of the screen provides a visual cue of the user's progress, ensuring they know exactly how many steps remain in the "2-minute" window.