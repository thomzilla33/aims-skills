---
name: aims-os-versioning-quality
description: Use as the final quality gate before delivering ANY output from the AIMS-OS versioning and handoff workflow. Run this after aims-os-feature-versioning, aims-os-scope-toggle, aims-os-eng-handoff-spec, aims-os-ds-component, or aims-os-prototype-screen produces an output. Ensures outputs are structurally identical every time, use correct terminology, and meet a world-class engineering-ready standard. Never skip this gate.
---

# AIMS-OS Versioning Output Quality Gate

Run every checklist section that applies before delivering output. This gate enforces two things:
1. **Consistency** — identical structure every time, no improvisation
2. **World-class bar** — immediately actionable for engineering, zero ambiguity

---

## Terminology lock

Use these terms exactly. Never substitute synonyms.

| Correct | Never use |
|---|---|
| **V1** | Phase 1, MVP, Sprint 1, Initial, Basic |
| **V1.5** | Phase 1.5, Iteration, Expansion phase |
| **V2 / Full Vision** | Phase 2, Final, Complete, Full version |
| **Deferred** | TBD, Future, Later, Someday |
| **DS-GAP** | Missing component, Custom component, Gap |
| **Scope toggle** | Version switcher, Phase selector, Toggle |
| **Acceptance criteria** | Success criteria, Requirements, Conditions |
| **In scope** | Included, Part of this, Covered |
| **Not in scope** | Excluded, Out of scope, Not included |
| `data-version` | version, scope-tag, tier |
| `ScreenLayout` | Screen wrapper, Page layout, Layout shell |

---

## Section 1 — version-map.md quality

Check every `version-map.md` file before delivering:

- [ ] File named exactly `version-map.md` (not `versions.md`, `scope.md`, etc.)
- [ ] Header: `## Feature: [Name]` — sentence case, specific feature name (not "New Feature")
- [ ] Every tier section present: `### V1 — Foundation`, `### V1.5 — Expansion`, `### V2 — Full Vision`
  - Skip V1.5 only if explicitly not needed — always document why (`<!-- No V1.5 — gap between V1 and V2 is small enough to skip -->`)
- [ ] All items are checkboxes: `- [ ] [specific behavior]` — never prose bullets
- [ ] `### Deferred (no version assigned)` section present, even if empty (`_None at this time._`)
- [ ] No vague items: "Add filters" ❌ → "Filter list by status (Active / Inactive / All)" ✅
- [ ] Each V1 item is the minimum — if it can be deferred to V1.5, it should be

**World-class bar:** A PM unfamiliar with the feature reads the version-map and immediately understands what ships when, with no follow-up questions needed.

---

## Section 2 — HTML prototype versioning quality

Check every versioned prototype file before delivering:

### Toggle component
- [ ] Toggle present in the file before `</body>` — not at the top, not in a component file
- [ ] `id="version-toggle"` present (exact ID — other scripts may reference it)
- [ ] `position: fixed; top: 16px; right: 16px; z-index: 9999` — exact values
- [ ] `SCOPE_TIERS` array matches the tiers defined in `version-map.md`
- [ ] Default scope on load is **V1** — never V2, never "full vision"
- [ ] `sessionStorage` persistence included — scope survives page navigation

### Element tagging
- [ ] Every element NOT in V1 has `data-version="v1.5"` or `data-version="v2"`
- [ ] V1 elements have **no** `data-version` attribute — they are the default visible state
- [ ] Deferred elements have `data-version="deferred"` — never `display: none` without an attribute
- [ ] `data-callout-for` callout annotations present for every V2 element hidden in V1 view
- [ ] No element has both `data-version` and hardcoded `display: none` — the toggle controls visibility

### Scope verification (manual test required)
- [ ] V1 scope: only V1 elements visible, callouts show for V2 elements
- [ ] V1.5 scope: V1 + V1.5 elements visible, V2 callouts remain
- [ ] V2 scope: everything visible, no callouts shown
- [ ] Toggle persists scope if user navigates to another page in the same prototype

**World-class bar:** An engineer opening the prototype for the first time immediately sees V1 scope, understands what's deferred, and can switch to Full Vision to see the complete picture — without reading any documentation.

---

## Section 3 — Engineering handoff spec quality

Check every handoff spec before delivering:

### Structure
- [ ] Header block complete: Prototype link, Feature ticket (ARP-[number]), Last updated date, Status
- [ ] "What this feature does" is 2–3 sentences — what problem, who uses it, core user action
- [ ] Every tier section has: Goal (1 sentence), In scope (checkboxes), Not in scope (list), Acceptance criteria (checkboxes)
- [ ] "UI states to implement" table present — all states mapped to tiers
- [ ] "Deferred" table present — even if empty (`| — | — | — |`)
- [ ] "Open questions" table present — even if empty

### Acceptance criteria quality
Run each criterion through this filter before including it:

| Test | Pass | Fail |
|---|---|---|
| **Observable?** | "Clicking Save closes the panel" | "Save is implemented" |
| **Binary?** | Either it does or it doesn't | "Works correctly" |
| **Specific?** | Names the element, state, or behavior | "Filters are supported" |
| **Eng-complete?** | Implies the full interaction | "Empty state shows" → must say what it shows |

- [ ] Every acceptance criterion passes all 4 filters above
- [ ] Empty state criterion present for every list surface in V1
- [ ] Error state criterion present for every async operation in V1
- [ ] No criterion describes implementation ("use React state") — only observable behavior

### Data model
- [ ] Mock data reference filled in — points to specific file + object name in the prototype
- [ ] At least one table row in API endpoints (even if `TBD` — engineering must know it's needed)

**World-class bar:** Engineering can read the spec, open the prototype, and start writing tickets with no PM clarification needed. Every question they would ask is answered in the spec.

---

## Section 4 — DS component quality

Check every new component before delivering:

- [ ] Phase 1 confirmed: component exists in Figma before any code was written (or DS-GAP filed)
- [ ] Phase 2 confirmed: Figma extraction script was run — output documented or pasted
- [ ] Zero hardcoded hex in the `.tsx` file — grep passes with no matches
- [ ] Zero hardcoded `rgb(` in the `.tsx` file — grep passes with no matches
- [ ] Named export only — `export function ComponentName` never `export default`
- [ ] TypeScript interface defined for all props
- [ ] Component registered in `src/components/ui/index.ts` (or `experimental/` if DS-GAP)
- [ ] Gallery entry added to `App.tsx` (append-only — no other changes)
- [ ] If DS-GAP: line 1 of file is the `// DS-GAP:` comment in correct format
- [ ] If overlay: overlay decision rule applied (can-ignore → SlideOut, must-respond → Modal)

**World-class bar:** Another engineer can read the component file with no context, understand every style choice, and extend it without breaking the token system.

---

## Section 5 — Prototype screen quality

Check every new screen before delivering:

- [ ] File in `src/screens/` — not in `components/`, not at root
- [ ] Named export — `export function ScreenName`
- [ ] Wrapped in `<ScreenLayout title="...">` as outermost element
- [ ] No `px-*`, `mx-*`, or `p-*` on the ScreenLayout's direct child (ScreenLayout owns outer spacing)
- [ ] `ListViewSection` used for filter + list patterns (not a custom filter implementation)
- [ ] `EmptyState` component used for zero-results (not a custom `<p>` or `<div>`)
- [ ] All colors via `var(--token-name)` — no hardcoded hex
- [ ] `App.tsx`: exactly one import added + one registry entry added — nothing else changed
- [ ] Screen title in `title` prop is sentence case: "Worker management" not "Worker Management"

**World-class bar:** The screen is indistinguishable in structure from any other screen in the repo — same outer shell, same spacing, same patterns.

---

## Final delivery check

Before sending any output to the user, confirm:

- [ ] All applicable sections above are checked
- [ ] Terminology matches the lock table (no synonyms)
- [ ] Output is complete — no `[placeholder]` or `TODO` left in delivered content
- [ ] Prototype link included in every deliverable that references a prototype
- [ ] If a Jira ticket is involved: `aims-os-output-quality` Section 4 (Jira) is also checked

**If any check fails:** Fix it before delivering. Do not mention the failure to the user — just fix it. The output they receive is always complete and correct.
