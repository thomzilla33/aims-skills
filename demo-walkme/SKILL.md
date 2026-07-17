---
name: demo-walkme
description: >
  Use when adding, applying, porting, or upgrading the guided demo tour
  (WalkMe-style product walkthrough) in an AIMS-OS HTML prototype — the floating
  "Demo" button, the spotlight + popover, and the step-by-step tour. Trigger when
  the user says "apply the demo walkme", "aplica el demo", "add the guided tour",
  "product tour", "walkthrough", "coach marks", "demo mode", or "port the
  settings.html tour to another prototype" (agentic-studio, data-studio,
  governance-studio, communication-hub, index, voice-channel-ux, etc.).
---

# AIMS-OS Demo WalkMe (Guided Tour)

## Overview
A self-guided product tour: a floating **Demo** button opens a spotlight that
rings one element at a time while a popover explains it and drives the app
(navigating routes, switching mode/persona, opening menus). Steps live in a
plain `TOUR_STEPS` array; a small engine paints them.

**Reference (gold standard):** the tour in `settings.html` of the AIMS-OS
prototype repo (`~/aims-os-prototype`, remote `aims-integration`). Copy that
pattern — do **not** invent a new one.

**"Mejorado" bar:** applying this skill means shipping the reference tour **plus
the 6 required upgrades below**. A plain port of `settings.html` is *not* enough.

## When to use
- Adding a first-run demo/walkthrough to any AIMS-OS prototype HTML file.
- Porting the `settings.html` tour to another surface.
- Upgrading an existing tour to the improved standard.

**Not for:** the React Dashboard-Widgets project, or one-off tooltips. This is
the single-file vanilla HTML/CSS/JS prototype pattern only.

## The 6 required upgrades (this is what "improved" means)
Every one MUST be present. They ship in `tour-engine.html` — verify each:

1. **Keyboard + focus-trap** — `←`/`→`/`Space` move, `Esc` exits; focus moves
   into the popover on each step and **Tab is trapped** inside it; focus returns
   to the Demo button on exit.
2. **Deep-link to a step** — `?tour=N` (1-based) in the URL auto-starts the tour
   at step N (shareable/resumable). `startTourAt(i)` is the entry point.
3. **Resume progress** — the current step persists to `localStorage`
   (`aims-tour-step`); the Demo button reads "Continue" and reopens where the
   user left off. Finishing clears it; a "Restart" link resets to step 1.
4. **Interactive spotlight (click-through)** — the dim is a 4-strip mask with a
   **hole over the target**, so the highlighted element stays clickable and the
   user can try the real action. Everything else is blocked.
5. **Accessibility** — popover is `role="dialog" aria-modal="true"`; a visually
   hidden `aria-live="polite"` region announces "Step X of N: <title>";
   `prefers-reduced-motion` disables the pulse and popover animation; the mask
   gives real contrast in light and dark.
6. **Responsive / mobile** — on narrow screens (< 560px) the popover docks as a
   bottom sheet instead of anchoring to the target; spotlight still rings the
   target; centered fallback when the target is off-screen or missing.

## How to apply (playbook)
1. **Copy the engine.** From `tour-engine.html` (this skill), paste the three
   marked blocks into the target prototype: `CSS` → inside `<style>`; `MARKUP`
   → just before the closing `</body>` (or near the toasts); `JS` → inside the
   main script block (or its own `<script>` before `</body>`). The engine's
   colors use `var(--token, fallback)`, so it works on **any** prototype even
   when the surface uses different token names (e.g. `agentic-studio` uses
   `--pri`/`--bd`/`--cb`, not `--accent`/`--line`/`--hover`) — no new tokens needed.
2. **Author the steps.** Replace the example `TOUR_STEPS` with 8–14 steps for
   *this* surface. Each `target` must be a real selector on the page; each
   `route` a real hash route. Use the schema table below. Keep bodies to
   2–3 sentences, bold the key noun, and reference real UI labels.
3. **Wire orchestration hooks.** If the surface has its own mode/persona/menus
   or tabbed detail pages, confirm the engine's hooks match this prototype's
   function names (`route()`, `setDetailTab()`, the switcher id). Rename to fit;
   drop hooks the surface doesn't have.
4. **Update the demo script.** Refresh `docs/DEMO.md` so the written walkthrough
   matches the steps (same order, same labels).
5. **Verify** against the checklist, in a real preview, in both themes.

## Step schema (quick reference)
| Field | Type | What it does |
|---|---|---|
| `title` | string | Popover heading (short). |
| `body` | HTML string | 2–3 sentences; `<strong>`, `<code>` allowed. |
| `route` | hash | Navigate here first (e.g. `#/integrations/slack`). |
| `target` | selector | Element to spotlight. Omit → centered popover. |
| `scrollToTarget` | bool | Smooth-scroll target under the topbar (2-pass reposition). |
| `setup` | function | Optional callback run before painting — drive app state (open a wizard, seed data, navigate) so the step's target exists. Great for flow-driving tours. |
| `mode` | string | Force app mode before painting (e.g. `browse`/`operate`). |
| `persona` | string | Force persona before painting (`admin`/`user`). |
| `detailTab` | string | Open a sub-tab after routing to a detail page. |
| `openSwitcher` | bool | Open the studio switcher for this step. |
| `pulse` | bool | Extra attention-pulse on the target. |

Example:
```js
{ title:'Filters live in a slideout',
  body:'The <b>All filters</b> button opens a right-side slideout with grouped sections.',
  route:'#/integrations', mode:'browse', target:'#catalogToolbar', scrollToTarget:true }
```

## Verify checklist
- [ ] Demo button appears bottom-left; pulse hidden after first run.
- [ ] Every step's `target` resolves (no silent centered fallback you didn't intend).
- [ ] `←`/`→`/`Esc` work; Tab stays inside the popover; focus returns to trigger on exit.
- [ ] `?tour=3` opens the tour at step 3.
- [ ] Reload mid-tour → button says "Continue" and reopens the same step; Finish clears it.
- [ ] The spotlighted element is actually clickable; the rest of the page is blocked.
- [ ] Screen reader announces each step; `prefers-reduced-motion` kills the pulse.
- [ ] At ≤ 375px the popover docks to the bottom and nothing overflows.
- [ ] Works in dark **and** light theme.
- [ ] `docs/DEMO.md` matches the step order and labels.

## Common mistakes
- **Porting only the baseline.** The `settings.html` engine lacks focus-trap,
  deep-link, resume, click-through, ARIA, and robust mobile. Ship the 6 upgrades.
- **Stale selectors.** Steps silently center when `target` doesn't match — after
  any layout change, re-check every `target`.
- **Blocking the target.** With the mask, keep the hole padding (~6px) so the
  target stays clickable; don't revert to a single full-screen blocker.
- **Forgetting `docs/DEMO.md`.** The written script must track the live steps.
- **New colors.** Reuse the prototype's existing tokens; don't hardcode hexes.

## Files
- `tour-engine.html` — drop-in CSS + MARKUP + JS with all 6 upgrades. Adapt, don't rewrite.
