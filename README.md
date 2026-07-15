# AIMS-OS Claude Skills

A shared library of Claude Code skills for the AIMS-OS team. These skills teach Claude how to work consistently across our design system, prototypes, and engineering handoffs — so every output looks the same and meets our standards, no matter who's running it.

---

## Installation

You only need to do this once.

```bash
git clone https://github.com/thomzilla33/aims-skills.git
cd aims-skills
./install.sh
```

Then restart Claude Code. That's it — the skills are now available in every project you open.

**To get updates** when new skills are added:

```bash
cd aims-skills
git pull
./install.sh
```

---

## What these skills do

When you're working in Claude Code, you don't invoke these skills manually. Claude detects when a skill applies and uses it automatically. You just describe what you want in plain language — Claude handles the rest.

The skills enforce two things across every output:
1. **Consistency** — same structure, same terminology, same component patterns every time
2. **Engineering-ready quality** — outputs are immediately actionable, no follow-up needed

---

## The 6 skills

### 1. `aims-os-feature-versioning`
**When Claude uses it:** Any time you need to show engineering what ships in V1 vs. what comes later.

This skill defines the versioning system for our prototypes. It creates a scope ladder (V1 → V1.5 → V2), tags every UI element in the prototype by delivery tier, and generates a `version-map.md` file that documents what's in each version.

**Example prompts:**
- *"I want to version the Worker Management feature — V1 is just the list with basic states, V2 is with filters and bulk actions"*
- *"Set up versioning for the Agentic Networks prototype — V1 is the overview tab only"*
- *"Create the scope ladder for Governance Policies"*

---

### 2. `aims-os-scope-toggle`
**When Claude uses it:** After versioning is set up, this adds the toggle control to the prototype.

The scope toggle is the floating V1 / V1.5 / Full Vision button that appears in the top-right corner of every versioned prototype. Engineers click it to switch between delivery tiers and see exactly what's in scope for their sprint vs. what's coming later.

It also handles the callout annotations — the dashed placeholder boxes that appear in V1 view to show engineers that something is planned but deferred.

**Example prompts:**
- *"Add the version toggle to the prototype"*
- *"The prototype needs a V1 / Full Vision switcher"*
- *"Add a two-tier toggle — just MVP and Full Vision, no V1.5"*

---

### 3. `aims-os-eng-handoff-spec`
**When Claude uses it:** When a feature is ready to hand off to engineering.

This skill generates the structured handoff document that goes alongside the prototype. It includes the acceptance criteria per version tier, the data model and API contracts implied by the prototype, every UI state that needs to be implemented (empty, loading, error, populated), and a table of open questions.

The document links directly to the Jira feature ticket and is the single source of truth for what engineering needs to build.

**Example prompts:**
- *"The Worker Management feature is ready — create the engineering handoff spec"*
- *"Write the handoff doc for Agentic Networks, V1 is the list view, V2 adds the network graph"*
- *"Generate the spec for the Governance feature so we can create the Jira tickets"*

---

### 4. `aims-os-ds-component`
**When Claude uses it:** Any time you need a new component in the `aims-os-design-system` repo.

This skill follows a strict 6-phase workflow: confirm the component exists in Figma, extract its tokens using a DevTools script, map those tokens to CSS custom properties, implement the component with zero hardcoded colors, register it in the component library, and run a compliance audit.

If the component doesn't exist in Figma yet, it files a **DS-GAP** — a placeholder in `src/components/experimental/` with a comment that flags it for design review by Michael before it can become a real DS component.

**Example prompts:**
- *"I need to implement the Stepper component from the design system"*
- *"Add a MetricCard component — it doesn't exist in the DS yet"*
- *"Implement the FiltersSlideout component from Figma"*

> **Note:** For the Figma token extraction step, you open the Figma file, select the component frame, open the DevTools console, and paste the extraction script Claude gives you. Then paste the output back into the chat. Claude handles everything else.

---

### 5. `aims-os-prototype-screen`
**When Claude uses it:** Any time you add a new screen to the HTML prototype repo.

Every screen in our prototypes follows the same structure: wrapped in `ScreenLayout` (mandatory — handles margins, scroll detection, header zones), uses `ListViewSection` for any filter + entity list pattern, and registers in `App.tsx` with exactly one import and one registry entry — nothing else changes in that file.

This skill enforces those rules so every screen is structurally identical to every other screen in the repo.

**Example prompts:**
- *"Add a Worker Management screen to the prototype"*
- *"Create the Governance Policies screen"*
- *"Add a new screen for the Agentic Networks overview"*

---

### 6. `aims-os-versioning-quality`
**When Claude uses it:** Automatically, before delivering any output from the other 5 skills.

This is the quality gate — you never invoke it directly. Claude runs it internally before sending you anything. It checks terminology (no "MVP" instead of V1, no "Phase 2" instead of V2), verifies every checklist item for the relevant workflow, and ensures acceptance criteria are observable and binary before they land in a handoff doc.

If something fails the gate, Claude fixes it before delivering. You always receive complete, correct output.

---

## How these skills chain together

Most workflows use multiple skills in sequence:

**Versioning a feature for engineering:**
```
1. aims-os-feature-versioning   → define scope ladder + tag prototype elements
2. aims-os-scope-toggle         → add the V1/V2 toggle to the prototype
3. aims-os-eng-handoff-spec     → generate the spec for engineering
4. aims-os-versioning-quality   → runs automatically before anything is delivered
```

**Adding a component to the design system:**
```
1. aims-os-ds-component         → Figma extraction → implementation → DS-GAP if missing
2. aims-os-prototype-screen     → add a screen that uses the new component
3. aims-os-versioning-quality   → runs automatically before anything is delivered
```

You don't need to think about the chain — just describe what you want and Claude figures out which skills apply.

---

## Terminology

These terms are locked. Claude will always use them correctly — and so should we, so everyone is speaking the same language.

| Use this | Never this |
|---|---|
| V1 | Phase 1, MVP, Sprint 1, Initial |
| V1.5 | Phase 1.5, Iteration, Expansion |
| V2 / Full Vision | Phase 2, Final, Complete |
| Deferred | TBD, Future, Later |
| DS-GAP | Missing component, Custom component |
| Scope toggle | Version switcher, Phase selector |
| Acceptance criteria | Success criteria, Requirements |
| In scope | Included, Covered |
| Not in scope | Excluded, Out of scope |

---

## Adding new skills

Have a workflow that should be codified? Add a new skill:

1. Create a folder with your skill name: `aims-os-[name]/`
2. Add a `SKILL.md` file inside it — see any existing skill for the format
3. Add the skill name to `install.sh`
4. Commit and push
5. Team runs `git pull && ./install.sh`

---

## Questions

Reach out to Thomas (thomas.gonzalez@aimsos.ai) for questions about these skills or to suggest new ones.
