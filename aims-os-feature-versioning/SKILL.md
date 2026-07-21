---
name: aims-os-feature-versioning
description: Use when a prototype or feature needs to communicate delivery scope to engineering — defining what ships in V1 vs what comes later. Use this when versioning a prototype, scoping a feature for engineering handoff, tagging UI elements by release tier, or creating the "scope ladder" that lets engineers start building while the full vision is defined. Trigger on any request involving version scope, V1 scope, feature phases, prototype versioning, or engineering delivery tiers.
---

# AIMS-OS Feature Versioning

## What This Is

Every feature in AIMS-OS has two views:
- **Full Vision** — the complete product experience, as designed
- **Scoped Version(s)** — what engineering actually builds first (V1), then expands (V1.5, V2)

This skill defines how to embed that versioning directly inside a prototype so engineering sees both at once: the full scope to understand where they're heading, and the clear boundary of what's in their current sprint.

The versioning system lives *in the prototype itself* — not in a separate doc. Engineers open the prototype, toggle to their scope, and immediately see what they're building and what's deferred.

---

## The Scope Ladder

Define tiers before touching any code:

| Tier | Name | What it means |
|---|---|---|
| **V1** | Foundation | Minimum functional scope. Core user journey only. No edge cases. |
| **V1.5** | Expansion | Adds depth — filters, states, secondary flows — without new surfaces |
| **V2** | Full Vision | Complete feature as designed. All states, edge cases, and interactions |

You don't need all three tiers every time. V1 + V2 is enough for most features. Add V1.5 only when the gap between V1 and V2 is large enough to need an intermediate stop.

**Define tiers in a `version-map.md`** at the feature root before writing a single line of prototype code:

```markdown
## Feature: [Name]

### V1 — Foundation
- [ ] [Core interaction 1]
- [ ] [Core interaction 2]
- [ ] Empty state
- [ ] Basic error state

### V1.5 — Expansion  
- [ ] [Filter/search capability]
- [ ] [Secondary action]
- [ ] [Additional entity type]

### V2 — Full Vision
- [ ] [Advanced interaction]
- [ ] [Edge case handling]
- [ ] [Power user flow]
- [ ] [Integration with surface X]
```

---

## Tagging UI Elements by Version

Inside the HTML prototype, every element that is NOT in V1 gets a version tag. Elements that are V1 have no tag — they're the default visible state.

### Version tag attributes

```html
<!-- V1 — no tag needed, visible by default -->
<div class="entity-row">...</div>

<!-- V1.5 — hidden by default, revealed when scope = V1.5 -->
<div class="entity-row" data-version="v1.5">...</div>

<!-- V2 — hidden by default, revealed when scope = V2 -->
<button class="btn-ghost" data-version="v2">Advanced filters</button>

<!-- Deferred entirely — annotated but never shown -->
<!-- data-version="deferred" items always stay hidden, shown only as callouts -->
<div data-version="deferred" data-note="Pending design: multi-select drag reorder"></div>
```

### Version classes on container elements

When an entire section belongs to a tier, tag the container:

```html
<section data-version="v2" class="advanced-config-panel">
  <!-- Everything inside is V2 -->
</section>
```

---

## The Versioning Toggle Component

Every versioned prototype gets a floating version toggle in the top-right corner. This is the control engineering uses to switch between scope views.

```html
<!-- Paste this before </body> in any versioned prototype -->
<div id="version-toggle" style="
  position: fixed; top: 16px; right: 16px; z-index: 9999;
  display: flex; align-items: center; gap: 8px;
  background: #13151A; border: 1px solid #2A2D35;
  border-radius: 8px; padding: 6px 10px;
  font-family: Inter, sans-serif; font-size: 12px; color: #94a3b8;
">
  <span style="font-weight: 600; color: #e2e8f0;">Scope</span>
  <div style="display: flex; gap: 4px;">
    <button onclick="setScope('v1')" id="scope-v1"
      style="padding: 3px 10px; border-radius: 5px; border: 1px solid #2563EB;
             background: #2563EB; color: white; font-size: 11px; cursor: pointer; font-weight: 600;">
      V1
    </button>
    <button onclick="setScope('v1.5')" id="scope-v1.5"
      style="padding: 3px 10px; border-radius: 5px; border: 1px solid #2A2D35;
             background: transparent; color: #94a3b8; font-size: 11px; cursor: pointer;">
      V1.5
    </button>
    <button onclick="setScope('v2')" id="scope-v2"
      style="padding: 3px 10px; border-radius: 5px; border: 1px solid #2A2D35;
             background: transparent; color: #94a3b8; font-size: 11px; cursor: pointer;">
      Full vision
    </button>
  </div>
</div>

<script>
const TIERS = ['v1', 'v1.5', 'v2'];

function setScope(selected) {
  const selectedIndex = TIERS.indexOf(selected);

  // Show elements at or below the selected tier
  document.querySelectorAll('[data-version]').forEach(el => {
    const tier = el.getAttribute('data-version');
    if (tier === 'deferred') return; // never show deferred items
    const tierIndex = TIERS.indexOf(tier);
    el.style.display = tierIndex <= selectedIndex ? '' : 'none';
  });

  // Update button states
  TIERS.forEach(tier => {
    const btn = document.getElementById('scope-' + tier);
    if (!btn) return;
    const isActive = tier === selected;
    btn.style.background = isActive ? '#2563EB' : 'transparent';
    btn.style.color = isActive ? 'white' : '#94a3b8';
    btn.style.borderColor = isActive ? '#2563EB' : '#2A2D35';
    btn.style.fontWeight = isActive ? '600' : '400';
  });
}

// Initialize — default to V1 view
setScope('v1');
</script>
```

---

## Version Callout Annotations

When V2 elements are hidden in V1 view, engineers still need to know something is planned there. Use callout annotations — lightweight visual cues that appear only in V1 scope to indicate deferred elements.

```html
<!-- Replace a deferred element with a callout in V1 -->
<div class="version-callout" data-show-in="v1" data-hide-in="v1.5,v2"
  style="border: 1px dashed #2A2D35; border-radius: 8px; padding: 12px 16px;
         color: #475569; font-size: 12px; display: flex; align-items: center; gap: 8px;">
  <span style="font-size: 16px;">📌</span>
  <span><strong style="color: #64748b;">V2:</strong> Advanced filter panel — 3 filter types, saved filter sets</span>
</div>
```

The callout disappears when the engineer switches to V2 scope (where the real component appears).

---

## Deferred Items Protocol

Some things won't ship in any defined version — they're placeholder design intent. Mark them clearly so engineering doesn't waste time wondering about them:

```html
<div data-version="deferred" style="display: none;"
     data-note="[Design pending] Drag-to-reorder within entity list — needs design review">
</div>
```

In `version-map.md`, list all deferred items at the bottom:

```markdown
### Deferred (no version assigned)
- Drag-to-reorder — pending design review
- Bulk export — pending data team API
- Real-time sync indicator — depends on WebSocket infra
```

---

## Implementation Order

1. **Define `version-map.md`** — tiers, scope per tier, deferred list
2. **Build to Full Vision** — build the complete prototype first, no version tags yet
3. **Tag downward** — add `data-version="v1.5"` and `data-version="v2"` attributes to elements that aren't in V1
4. **Add the toggle** — paste the toggle component before `</body>`
5. **Add callouts** — for each V2 element hidden in V1 view, add a callout annotation
6. **Test all three scopes** — click through V1 → V1.5 → V2 and verify transitions are correct
7. **Hand off** — use `aims-os-eng-handoff-spec` to create the accompanying spec

---

## Versioning in the React Project

For `Dashboard-Widgets` (React), use a `useScope()` hook instead of the HTML toggle:

```jsx
// state/ScopeContext.jsx
import { createContext, useContext, useState } from 'react'
const ScopeContext = createContext('v1')
export const ScopeProvider = ({ children }) => {
  const [scope, setScope] = useState('v1')
  return <ScopeContext.Provider value={{ scope, setScope }}>{children}</ScopeContext.Provider>
}
export const useScope = () => useContext(ScopeContext)

// In any component:
const { scope } = useScope()
const tiers = ['v1', 'v1.5', 'v2']
const showIfV2 = tiers.indexOf(scope) >= tiers.indexOf('v2')
{showIfV2 && <AdvancedFiltersPanel />}
```

---

## Feature Changelog

Every versioned feature needs a changelog so engineering and the rest of the team can see at a glance what changed between versions — what's new, what was removed, what was updated in each view.

The changelog lives at the bottom of `version-map.md`, one block per version tier. It is updated every time a tier is defined or revised.

### Format

```markdown
---

## Changelog

### V1 — Foundation
**Release target:** [sprint or date]

**New in this version:**
- [View or surface name]: [what was added — specific feature, not vague description]
- [View or surface name]: [what was added]

**Updated in this version:**
- [View or surface name]: [what changed from the previous state / baseline]

**Removed / not included:**
- [Feature or element]: [why it was cut — deferred to V1.5, pending API, etc.]

---

### V1.5 — Expansion
**Release target:** [sprint or date]

**New in this version:**
- [View or surface name]: [what was added on top of V1]

**Updated in this version:**
- [View or surface name]: [what changed compared to V1]

**Removed / not included:**
- [Feature]: [reason]

---

### V2 — Full Vision
**Release target:** [sprint or date]

**New in this version:**
- [View or surface name]: [what completes the full experience]

**Updated in this version:**
- [View or surface name]: [what changed compared to V1.5]

**Removed / not included:**
- _None — this is the complete version._
```

### Rules for writing changelog entries

- **One entry per view or surface** — if a version touches the Overview tab, the Workers list, and a SlideOut detail, write a separate bullet for each. Don't bundle them.
- **New** = something that didn't exist in the previous tier. Be specific: "Workers list: added bulk select with action bar" not "added bulk actions".
- **Updated** = something that existed but changed. Describe the before and after: "Filter bar: was 2 static filters, now has dynamic dropdowns + search".
- **Removed / not included** = anything cut from that tier and why. Engineering needs to know what's intentionally missing so they don't build it early.
- **Release target** = sprint name or approximate date. Approximate is fine — "Q3 sprint 2" works. Never leave it blank.

### Real example

```markdown
## Changelog

### V1 — Foundation
**Release target:** Sprint 14 (July 2026)

**New in this version:**
- Workers list: entity list with name, status badge, last active timestamp, and Eye action
- Workers list: empty state with "Add your first worker" CTA
- Worker detail SlideOut: name, status, description, created date — read-only

**Updated in this version:**
- n/a — this is the first version

**Removed / not included:**
- Workers list: bulk select — deferred to V1.5, requires backend batch API
- Workers list: search and filter bar — deferred to V1.5
- Worker detail: edit mode — deferred to V2, pending UX review

---

### V1.5 — Expansion
**Release target:** Sprint 16 (August 2026)

**New in this version:**
- Workers list: search input + 2 filter dropdowns (Status, Type)
- Workers list: bulk select with "Archive" and "Change status" actions
- Worker detail SlideOut: activity log tab showing last 10 events

**Updated in this version:**
- Workers list: Eye action now opens the updated SlideOut with the activity tab
- Empty state: updated copy to reflect filter context ("No workers match your filters")

**Removed / not included:**
- Worker detail: edit mode — still deferred to V2

---

### V2 — Full Vision
**Release target:** Sprint 20 (October 2026)

**New in this version:**
- Worker detail: inline edit mode for name, description, and status
- Worker detail: linked runs tab showing the last 25 execution logs with status indicators
- Workers list: saved filter sets — users can name and save filter combinations

**Updated in this version:**
- Worker detail SlideOut: promoted to full-page detail view (no longer a SlideOut)
- Filter bar: expanded to 4 filters + "All filters" slideout

**Removed / not included:**
- _None — this is the complete version._
```

---

## Checklist Before Handoff

- [ ] `version-map.md` exists and defines all tiers
- [ ] All elements tagged with correct `data-version` attribute
- [ ] Toggle component present and functional
- [ ] V1 scope tested — only V1 elements visible
- [ ] V1.5 scope tested — V1 + V1.5 elements visible
- [ ] V2 scope tested — everything visible
- [ ] Callouts appear in V1 for deferred V2 elements
- [ ] Deferred items listed in `version-map.md`
- [ ] Changelog written for every tier — one entry per view, release target filled in
- [ ] `aims-os-eng-handoff-spec` completed for this feature
