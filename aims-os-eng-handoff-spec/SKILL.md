---
name: aims-os-eng-handoff-spec
description: Use when creating the engineering handoff document that accompanies a versioned prototype. Use this when a feature is ready to hand to engineering, when writing acceptance criteria per version tier, when defining API contracts or data shapes implied by a prototype, or when engineering needs a structured spec that maps to the prototype's V1/V2 scope. Always pair with aims-os-feature-versioning and aims-os-prototype-handoff.
---

# AIMS-OS Engineering Handoff Spec

The handoff spec bridges the versioned prototype and the Jira tickets. It tells engineering exactly what to build in each version, what to defer, and how to interpret the prototype. It lives alongside the Jira ARP tickets — link it from the Feature-level ticket.

---

## When to create this

Create one spec per feature (not per screen). The spec covers all version tiers for that feature. One document, one source of truth.

Timing: **after the prototype is versioned** (see `aims-os-feature-versioning`) and **before creating Jira tickets** (see `aims-os-prototype-handoff`).

---

## Spec Template

````markdown
# [Feature Name] — Engineering Handoff Spec

**Prototype:** [link to prototype]  
**Feature ticket:** ARP-[number]  
**Last updated:** [date]  
**Status:** [Draft / Ready for review / Approved]

---

## What this feature does

[2–3 sentences. What problem does it solve? Who uses it? What's the core user action?]

---

## Delivery tiers

### V1 — Foundation
**Goal:** [One sentence — the minimum useful thing this delivers]

**In scope:**
- [ ] [Specific behavior 1]
- [ ] [Specific behavior 2]
- [ ] Empty state: [describe]
- [ ] Error state: [describe]

**Not in scope (deferred to V1.5 / V2):**
- [What's explicitly excluded and why]

**Acceptance criteria:**
- [ ] [Observable behavior — verb + what the user sees/can do]
- [ ] [Observable behavior]
- [ ] [Edge case behavior]

---

### V1.5 — Expansion *(if applicable)*
**Goal:** [What this adds on top of V1]

**In scope:**
- [ ] [Additional behavior]

**Acceptance criteria:**
- [ ] [Observable behavior]

---

### V2 — Full Vision
**Goal:** [The complete experience]

**In scope:**
- [ ] [Complete feature set]

**Acceptance criteria:**
- [ ] [Observable behavior]

---

## Data model / API contracts

[What data shapes does this feature need? What does engineering need to provide or expect?]

### Entities involved
- **[EntityName]**: [what fields are used, which are new vs existing]

### API endpoints (if known)
| Method | Path | Purpose |
|---|---|---|
| GET | `/api/[path]` | [What it returns] |
| POST | `/api/[path]` | [What it creates] |

### Mock data reference
[Which file/object in the prototype's mock data corresponds to the real data shape]
- `src/data/mock.js` → `[OBJECT_NAME]` (lines [N–N])

---

## UI states to implement

Every interactive surface needs all states handled. Check off what's in each tier.

| State | V1 | V1.5 | V2 |
|---|---|---|---|
| Empty (zero items) | ✅ | — | — |
| Loading skeleton | ✅ | — | — |
| Populated (1–N items) | ✅ | — | — |
| Error / failed to load | ✅ | — | — |
| Search / filter applied | — | ✅ | — |
| Bulk selection active | — | — | ✅ |
| [Other state] | | | |

---

## Design constraints

[Anything from the design system or prototype that engineering must respect]

- All colors via `aims-*` token prefix — no hardcoded hex
- Overlay rule: [Modal / SlideOut — and why based on the can-the-user-ignore-it rule]
- Icon convention: [any specific icon choices and why]
- Animation: [if any transition is required, describe it]

---

## What's deferred (no version assigned)

These items appear in the Full Vision prototype but have no delivery commitment:

| Item | Reason deferred | Owner |
|---|---|---|
| [Feature] | [Pending design / API / infra] | [Design / Backend / TBD] |

---

## Open questions

| Question | Asked by | Status |
|---|---|---|
| [Question] | [PM / Design / Eng] | [Open / Answered] |

---

## Changelog

| Date | Change | Author |
|---|---|---|
| [date] | Initial spec | [name] |
````

---

## Writing good acceptance criteria

Acceptance criteria are the contract between PM and engineering. They must be:

- **Observable** — what the user sees or can do, not how it's implemented
- **Binary** — either it passes or it doesn't, no ambiguity
- **Specific** — reference the actual element, state, or behavior

```
✅ Good:
- [ ] Clicking "Save" closes the SlideOut and adds the item to the list without page reload
- [ ] Empty state shows "No workers yet" with an "Add worker" CTA
- [ ] Filter chip appears above the list when a filter is active; clicking X removes it

❌ Bad:
- [ ] The feature works correctly
- [ ] Save functionality implemented
- [ ] Filters are supported
```

---

## Linking to Jira

After writing the spec, link it from ARP tickets:

- **Feature ticket** (level 2): paste the full spec content in the Description field
- **Sub Feature / Version tickets** (level 1): link back to the Feature ticket; paste only the relevant tier's acceptance criteria in each Sub Feature ticket

Use `aims-os-prototype-handoff` to create the Jira ticket hierarchy via `anthropic-skills:jira-arp-ticket-creator`.

---

## Checklist before sharing with engineering

- [ ] Prototype link is live and scoped to V1 by default
- [ ] Each tier has clear "in scope" and "not in scope" lists
- [ ] Acceptance criteria are observable and binary (not implementation descriptions)
- [ ] Data model / mock data reference is filled in
- [ ] All UI states (empty, loading, error, populated) are covered for V1
- [ ] Open questions are listed — none left hidden
- [ ] Spec is linked from the Feature-level Jira ticket
