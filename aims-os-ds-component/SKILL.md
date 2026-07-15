---
name: aims-os-ds-component
description: Use when implementing a new UI component for the AIMS-OS design system repo (github.com/cachilupis/aims-os-design-system). Use when extracting tokens from Figma, creating a component in src/components/ui/, filing a DS-GAP for a missing component, or auditing token compliance. Trigger on any request involving new DS components, Figma token extraction, design system compliance, or the aims-os-design-system repo.
---

# AIMS-OS Design System Component

Project root: `aims-os-design-system` repo (cloned from `github.com/cachilupis/aims-os-design-system`)

The design system is the **single source of truth** for all UI in AIMS-OS prototypes. No color, spacing, or radius value may be invented — everything comes from Figma via the token extraction process below.

---

## The Six-Phase Workflow

### Phase 1 — Confirm the component exists in Figma

Before writing any code, confirm the component is in the Figma file `v6rmYKA2zmyXWOahlxLOeI`.

If it exists in Figma → proceed to Phase 2.  
If it does NOT exist in Figma → file a DS-GAP (see below). Stop here.

---

### Phase 2 — Extract tokens from Figma DevTools

Open the Figma file, select the component frame, open DevTools (Plugins → Developer → Open console), and run this extraction script:

```javascript
// Paste in Figma DevTools console
(function extractTokens() {
  const selected = figma.currentPage.selection[0];
  if (!selected) { console.log('Select a frame first'); return; }

  function resolveAlias(value, vars) {
    if (!value || typeof value !== 'object') return value;
    if (value.type === 'VARIABLE_ALIAS') {
      const resolved = vars.find(v => v.id === value.id);
      return resolved ? resolveAlias(resolved.valuesByMode[Object.keys(resolved.valuesByMode)[0]], vars) : value;
    }
    return value;
  }

  const vars = figma.variables.getLocalVariables();
  const tokens = {};

  function walk(node) {
    if (node.boundVariables) {
      Object.entries(node.boundVariables).forEach(([prop, binding]) => {
        const varObj = vars.find(v => v.id === (binding.id || binding));
        if (varObj) {
          const resolved = resolveAlias(varObj.valuesByMode[Object.keys(varObj.valuesByMode)[0]], vars);
          tokens[`${node.name}__${prop}`] = { variable: varObj.name, resolved };
        }
      });
    }
    if ('children' in node) node.children.forEach(walk);
  }

  walk(selected);
  console.log(JSON.stringify(tokens, null, 2));
})();
```

Copy the output. Every value in the output is a CSS custom property reference — map it to `var(--token-name)` from `src/index.css`.

---

### Phase 3 — Map Figma variables to CSS custom properties

Cross-reference the extraction output against `src/index.css`. All Figma variable names map directly to CSS custom properties:

| Figma variable | CSS custom property |
|---|---|
| `canvas` | `var(--canvas)` |
| `surface` | `var(--surface)` |
| `primary` | `var(--primary)` |
| `error` | `var(--error)` |
| `alert` | `var(--alert)` |
| `success` | `var(--success)` |

**Rule: zero hardcoded hex in `.tsx` files.** If the extraction gives you `#2563EB`, find its CSS variable. If no variable exists, file a token request to design before proceeding.

---

### Phase 4 — Implement the component

Place the component in `src/components/ui/[ComponentName].tsx`.

```typescript
// src/components/ui/ExampleCard.tsx
import { cn } from '@/lib/utils'

interface ExampleCardProps {
  variant?: 'default' | 'highlight'
  children: React.ReactNode
  className?: string
}

export function ExampleCard({ variant = 'default', children, className }: ExampleCardProps) {
  return (
    <div
      className={cn(
        'rounded-xl border p-4',
        'bg-[var(--surface)] border-[var(--border)]',
        variant === 'highlight' && 'border-[var(--primary)]',
        className
      )}
    >
      {children}
    </div>
  )
}
```

**Non-negotiable rules:**
- Named exports only — never `export default`
- All colors via `var(--token-name)` — no hardcoded hex
- Dark mode is the only mode — the DS is dark-first, no `dark:` variants needed (tokens handle it)
- Props use TypeScript interfaces, not `type`
- Component file name = PascalCase = component function name

---

### Phase 5 — Register the component

Add the export to `src/components/ui/index.ts`:

```typescript
export { ExampleCard } from './ExampleCard'
```

Add to `src/App.tsx` as an import + usage in the component gallery (append-only — no new functions or routes):

```typescript
import { ExampleCard } from './components/ui'
// Inside the gallery section:
<ExampleCard>Example content</ExampleCard>
<ExampleCard variant="highlight">Highlighted</ExampleCard>
```

---

### Phase 6 — Token compliance audit

Before committing, run the audit:

```bash
# Check for any hardcoded hex in component files
grep -rn '#[0-9A-Fa-f]\{3,6\}' src/components/ui/[ComponentName].tsx

# Check for any hardcoded rgb/rgba
grep -rn 'rgb(' src/components/ui/[ComponentName].tsx

# Should return empty — any match is a violation
```

Also verify the component renders in the Figma file via the Code Connect mapping if one exists (`Button.figma.tsx` at repo root shows the pattern).

---

## DS-GAP Protocol

When a needed component does **not** exist in `src/components/ui/` and is not in Figma:

1. Create the file in `src/components/experimental/[ComponentName].tsx`
2. Line 1 of the file must be the DS-GAP comment:
   ```typescript
   // DS-GAP: ComponentName — [description of what's needed]. Closest DS component: [nearest existing component]
   ```
3. Build the component using token-only styling (same rules as above — no hardcoded hex)
4. Do NOT export from `src/components/ui/index.ts` — experimental components are not part of the public DS
5. Add a note in the relevant prototype or Jira ticket: "Uses experimental `ComponentName` — pending design review by Michael"

**Only the design lead (Michael) can promote from `experimental/` to `ui/`.** Never move files yourself.

---

## Overlay Decision Rule

When choosing between overlays for a new component:

```
Can the user ignore this and continue working? → SlideOut
Must the user respond before doing anything else? → ModalDialog
```

Maximum 1 Modal + 1 SlideOut active at the same time. Never nest modals.

Dropdowns and menus must use `position: fixed` computed from `getBoundingClientRect()` — never inside an `overflow: hidden` parent.

---

## Component checklist

- [ ] Component exists in Figma before code was written (or DS-GAP filed)
- [ ] Token extraction script was run — no values invented
- [ ] Zero hardcoded hex or rgb in the `.tsx` file
- [ ] Named export (no `export default`)
- [ ] TypeScript interface for props
- [ ] Registered in `src/components/ui/index.ts` (or `experimental/` if DS-GAP)
- [ ] Added to gallery in `App.tsx`
- [ ] Grep audit passed (no hardcoded colors)
- [ ] Overlay rule applied if component is a modal/popover
