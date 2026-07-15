---
name: aims-os-ds-component
description: Use when implementing a new UI component, assembling a prototype screen, or working inside the AIMS-OS design system repo (github.com/cachilupis/aims-os-design-system). Use when extracting tokens from Figma, creating a component in src/components/ui/, filing a DS-GAP for a missing component, composing list views or overview tabs, wiring filters or overlays, or auditing token compliance. Trigger on any request involving DS components, Figma token extraction, prototype screens, WidgetCanvasView, ListViewSection, ScreenLayout, or the aims-os-design-system repo.
---

# AIMS-OS Design System — Component & Screen Reference

Project root: `aims-os-design-system` repo (`github.com/cachilupis/aims-os-design-system`)

**Stack:** React + TypeScript + Tailwind + shadcn/ui. Dark-first. Inter font.

---

## Non-negotiables (read first)

- Use ONLY components from `src/components/ui/`. Never hand-roll a button, input, card, table, sidebar, or topbar.
- All colors via `var(--token-name)`. Zero hardcoded hex, rgba, px spacing, or radii in `.tsx` files.
- Default theme is dark: background = `var(--canvas)`, surfaces = `var(--surface)`, borders = `var(--field-border)`.
- Match existing component variants only. Never invent new variants.
- Before generating any screen: check `src/components/ui/` first. If a Figma URL is given, fetch it via Figma MCP before writing code.

---

## Building a new component — 6-phase workflow

### Phase 1 — Confirm in Figma

Confirm the component exists in Figma file `v6rmYKA2zmyXWOahlxLOeI`.

- Exists in Figma → proceed to Phase 2
- Does NOT exist → try DS composition first (see DS-GAP section). If no composition works → file DS-GAP. Stop.

### Phase 2 — Extract tokens from Figma DevTools

Open Figma, select the component frame, go to **Plugins → Developer → Open console**, run:

```javascript
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

Paste the output back — every value maps to a CSS custom property from `src/index.css`.

### Phase 3 — Map to CSS custom properties

| Figma variable | CSS custom property |
|---|---|
| `canvas` | `var(--canvas)` |
| `surface` | `var(--surface)` |
| `primary` | `var(--primary)` |
| `error` | `var(--error)` |
| `alert` | `var(--alert)` |
| `success` | `var(--success)` |
| `field-border` | `var(--field-border)` |

If extraction gives a raw hex, find its variable. If no variable exists → request token from design before proceeding.

### Phase 4 — Implement

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
    <div className={cn(
      'rounded-xl border p-4',
      'bg-[var(--surface)] border-[var(--field-border)]',
      variant === 'highlight' && 'border-[var(--primary)]',
      className
    )}>
      {children}
    </div>
  )
}
```

Rules: named export only, `interface` not `type` for props, PascalCase file = function name, no `dark:` variants (tokens handle dark mode).

### Phase 5 — Register

Add to `src/components/ui/index.ts`:
```typescript
export { ExampleCard } from './ExampleCard'
```

Add to `src/App.tsx` (append-only — one import + one gallery entry, nothing else):
```typescript
import { ExampleCard } from './components/ui'
// In gallery: <ExampleCard>Example</ExampleCard>
```

### Phase 6 — Token compliance audit

```bash
grep -rn '#[0-9A-Fa-f]\{3,6\}' src/components/ui/ComponentName.tsx
grep -rn 'rgb(' src/components/ui/ComponentName.tsx
# Both must return empty
```

---

## Adding a PM prototype screen

Each PM prototype is a single file in `src/screens/`. App.tsx gets only a registration entry.

**File:** `src/screens/[pm-name]-[feature].tsx`

### Step 1 — Wrap in ScreenLayout (mandatory, no exceptions)

```tsx
import { ScreenLayout }    from "@/components/layouts/screen-layout"
import { ListViewSection } from "@/components/layouts/list-view-section"
import type { SidebarItem } from "@/components/ui/sidebar"

const SIDEBAR_ITEMS: SidebarItem[] = [
  { id: "ai-workers", label: "AI Workers", icon: "Bot" },
]

export default function MyScreen() {
  return (
    <ScreenLayout
      workspaceName="Tenant Name"
      userName="PM Name"
      userEmail="pm@company.com"
      sidebarItems={SIDEBAR_ITEMS}
      activeSidebarId="ai-workers"
      header={(isScrolled) => (
        <Header
          size={isScrolled ? "compress" : "size-l"}
          title="Page Title"
          description="Page description."
          primaryAction={<Button variant="main" size="sm">New Item</Button>}
        />
      )}
      pagination={
        filtered.length > pageSize
          ? <Pagination currentPage={page} totalItems={filtered.length} itemsPerPage={pageSize} onPageChange={setPage} />
          : undefined
      }
    >
      <ListViewSection items={pagedItems} filterSlots={...} />
    </ScreenLayout>
  )
}
```

`ScreenLayout` enforces: 32px horizontal margin, 8px top / 64px bottom padding, 56px collapsed sidebar, header outside scroll area, `isScrolled` at `scrollTop > 16px`. Never add `px-*` or `mx-*` to its direct child.

**Pagination lives in `ScreenLayout`** — pass it to the `pagination` prop, not inside `ListViewSection`.

### Step 2 — Register in App.tsx (only change)

```tsx
import MyScreen from "./screens/pm-juan-dashboard"
{ id: "proto-juan-dashboard", label: "Dashboard — Juan", description: "Adoption metrics view", author: "Juan", component: MyScreen },
```

---

## Pattern composition rules

Always use established patterns from `src/App.tsx`. Never compose from scratch.

### List View screens — stack in this order

1. `Topbar` — top navigation
2. `Sidebar` inside `AppBackground` — left nav
3. Content area:
   - `Tabs` — "Where am I?" (e.g. All Workers / Teams)
   - `SwitchTab` — "How am I viewing?" (List / Grid) — only when needed
   - `Filters` — always present when there's a filterable dataset
   - `EntityList` inside `CardContainer` — 12px gap between cards
   - `Pagination` — only when `total_results > rows_per_page`

Use `ListViewSection` from `src/components/layouts/list-view-section.tsx` to get this pre-wired.

**Navigation depth:** max 2 layers. 8px gap between Tabs and Filter bar. 24px gap between Filters and first card row.

**Entity item action order:** primary → secondary → tertiary (Eye/preview).
- Eye icon belongs ONLY in the tertiary slot. Never use Eye as the leading entity icon.
- Eye button always opens a `SlideOut`.

**HighlightCard:** always `style="default"`. Never use `primary-bg`, `green-bg`, `orange-bg` — deprecated. Color differentiation goes only in `iconName` and `feedbackType` props.

### Filter system — 3 layers in order

1. `Filters` component — always visible
2. "All Filters" button → opens `FiltersSlideout`
3. Applied chips (`Tag` or `Chip`) — appear below filters after Apply

Rules:
- Closing `FiltersSlideout` without Apply discards draft state — list does not change
- Apply → sync draft to applied → reset pagination to page 1 → close slideout
- Chips are optional; the system works without them

### Overview tabs — always WidgetCanvasView

Any tab labelled "Overview" MUST use `WidgetCanvasView`. Never hand-roll a CSS grid.

```tsx
import { WidgetCanvasView } from "@/components/layouts/widget-canvas-view"
import type { CanvasSlot }  from "@/components/layouts/widget-canvas-view"
import { HighlightIcon }    from "@/components/ui/highlight-icon"

function KpiContent({ value, feedback, iconName, iconVariant }) {
  return (
    <div style={{ padding: "4px 16px 16px" }}>
      <div className="flex items-center justify-between">
        <span style={{ fontSize: 24, fontWeight: 700, lineHeight: 1, color: "var(--color-text-title)" }}>{value}</span>
        <HighlightIcon size="lg" variant={iconVariant} iconName={iconName} />
      </div>
      <span style={{ fontSize: 12, color: "var(--color-text-subtitle)", marginTop: 6, display: "block" }}>{feedback}</span>
    </div>
  )
}

<WidgetCanvasView
  initialSlots={[
    { uid: "total-workers", title: "Total Workers", colSpan: 1,
      content: <KpiContent value={9} feedback="All categories" iconName="Bot" iconVariant="informative" /> },
    { uid: "recent-activity", title: "Recent Activity", colSpan: 2, widthClass: "wide",
      content: <div style={{ padding: "0 16px 16px" }}><Table columns={...} data={...} size="sm" /></div> },
    { uid: "timeline", title: "Timeline", colSpan: 3, widthClass: "full",
      content: <MyTimelineContent /> },
  ] satisfies CanvasSlot[]}
/>
```

- `colSpan`: 1 = narrow (1/3), 2 = wide (2/3), 3 = full (3/3)
- Every slot needs a unique `uid`
- Pass only inner content — `WidgetFather` chrome is added by `WidgetCanvasView`. Never wrap content in another `WidgetFather`.
- KPI padding: `"4px 16px 16px"`. Table/feed padding: `"0 16px 16px"`
- HighlightIcon variants: `informative` (blue), `success` (green), `neutral` (grey), `alert` (yellow), `error` (red)

### Logs / activity tabs — always Pagination

```tsx
const [logsPage, setLogsPage] = useState(1)
const [logsPageSize, setLogsPageSize] = useState(10)

pagination={
  mainTab === "logs"
    ? <Pagination currentPage={logsPage} totalItems={allLogs.length} itemsPerPage={logsPageSize}
        onPageChange={setLogsPage} onItemsPerPageChange={n => { setLogsPageSize(n); setLogsPage(1) }}
        rowsPerPageOptions={[10, 25, 50]} />
    : undefined
}
```

Default page size: 10. Options: [10, 25, 50]. Never share pagination state between tabs.

### Overlays

- `ModalDialog` — user MUST stop (destructive action, confirmation, critical form)
- `SlideOut` — user can continue browsing (details, filters, context)
- Rule: can the user ignore it? → SlideOut. Must they respond? → Modal.
- Max 1 Modal + 1 SlideOut active at a time. Never nest modals.

### Dropdown menus

Dropdowns must appear centered below the clicked button — never at mouse position.

```tsx
onClickCapture={(e: React.MouseEvent) => {
  const btn = (e.target as HTMLElement).closest('button')
  const left = btn
    ? btn.getBoundingClientRect().left + btn.getBoundingClientRect().width / 2
    : e.clientX
  setAnchor({ left, top: (e.currentTarget as HTMLElement).getBoundingClientRect().bottom })
}}
// Dropdown:
style={{ position: "fixed", left: anchor.left, top: anchor.top + 4, transform: "translateX(-50%)", zIndex: 10001 }}
```

### Input and Textarea

Never pass the `label` prop in desktop PM screen files (`src/screens/*.tsx`). Use `placeholder` only. The floating label is a mobile convention.

---

## DS-GAP protocol

When a needed component does not exist in `src/components/ui/`:

**Step 1 — Try composition.** Can it be achieved by combining existing DS components (`CardContainer`, `Tag`, `EntityList`, `Button`, `HighlightCard`, etc.)? If yes, compose — no new file needed.

**Step 2 — If genuine gap:** create in `src/components/experimental/[ComponentName].tsx`.

```typescript
// DS-GAP: ComponentName — description of what's needed. Closest DS component: CardContainer.
```

Line 1 must be the `// DS-GAP:` comment. Token-only styling. Accept `variant?`, `size?`, `className?` props minimum. Never export from `src/components/ui/index.ts`.

**Only Michael (Product Design) can promote from `experimental/` to `ui/`.** Never move files yourself. Promotion requires a Figma node first.

---

## Anti-patterns — never do these

- Hardcoding `#hex` or `rgba()` in `.tsx`
- `position: absolute` for overlays — use `position: fixed` + `getBoundingClientRect()`
- Rendering dropdowns inside `overflow: hidden` parents
- Creating a new button/input/card when `src/components/ui/` has one
- Two secondary buttons side by side — order is always primary → secondary → tertiary
- Adding a filter chip before Apply is clicked
- Opening a Modal for non-destructive content — use SlideOut
- Loading indicator for operations under 300ms
- Two loading indicators on the same view simultaneously
- `label` prop on `Input` or `Textarea` in desktop screens
- `WidgetCanvasSection` or hand-rolled CSS grid for Overview tabs — use `WidgetCanvasView`

---

## Validation checklist (run in this order)

- [ ] `npx tsc -b --noEmit` → 0 errors
- [ ] Browser screenshot on `localhost:5173` — compare against DS pattern page
- [ ] Overview tab uses `WidgetCanvasView`, Workers tab uses `ListViewSection`, Logs tab shows `Pagination`
- [ ] Token audit grep returns empty (no hardcoded hex/rgb)
- [ ] Michael visual sign-off on localhost before any push

Run `/ds-health` before any prototype session to audit the full repo for violations.
