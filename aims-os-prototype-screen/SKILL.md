---
name: aims-os-prototype-screen
description: Use when adding a new screen to the AIMS-OS HTML prototype repo (the one with index.html, agentic-studio.html, etc. — NOT the React Dashboard-Widgets project). Use this for any new prototype page, screen layout, list-view section, or App.tsx registration in the design system repo. Trigger on requests to add a screen, page, or view to the HTML prototypes or the aims-os-design-system repo.
---

# AIMS-OS Prototype Screen

This skill covers the HTML prototype repo (`aims-os-design-system`) — not the React `Dashboard-Widgets` project. For React components, see `aims-os-react-component`.

---

## The Three Rules

1. **`ScreenLayout` is mandatory** — every screen wraps its content in `<ScreenLayout>`. No exceptions.
2. **`App.tsx` is append-only** — one import + one registry entry. No new functions, no new routes, no restructuring.
3. **Token-only styling** — all colors via `var(--token-name)` from `src/index.css`. Zero hardcoded hex.

---

## Anatomy of a Prototype Screen

Every screen is a single `.tsx` file in `src/screens/`:

```typescript
// src/screens/MyNewScreen.tsx
import { ScreenLayout } from '../components/layouts/screen-layout'
import { ListViewSection } from '../components/layouts/list-view-section'
// Import DS components as needed
import { Button, CardContainer } from '../components/ui'

export function MyNewScreen() {
  return (
    <ScreenLayout
      title="Screen Title"
      subtitle="Optional supporting description"
      actions={
        // Top-right action area — primary CTA goes here
        <Button variant="default">Primary action</Button>
      }
    >
      {/* Screen body — content goes here */}
      <CardContainer>
        {/* ... */}
      </CardContainer>
    </ScreenLayout>
  )
}
```

---

## ScreenLayout props

| Prop | Type | Required | Purpose |
|---|---|---|---|
| `title` | string | Yes | Page H1 — sentence case |
| `subtitle` | string | No | Supporting context line |
| `actions` | ReactNode | No | Top-right action area |
| `children` | ReactNode | Yes | Page body content |

`ScreenLayout` handles:
- 32px horizontal margin (enforced — never add `px-*` to the screen's direct child)
- Scroll detection (adds header shadow on scroll)
- Header zone with title + actions

**Never add top-level padding or margin inside a screen.** `ScreenLayout` owns all outer spacing.

---

## Using ListViewSection

For screens that show a filterable list of entities, use `ListViewSection` — it wires `Filters` + `EntityList` together:

```typescript
import { ListViewSection } from '../components/layouts/list-view-section'

// Inside ScreenLayout children:
<ListViewSection
  filters={[
    { id: 'all', label: 'All', count: 42 },
    { id: 'active', label: 'Active', count: 31 },
    { id: 'inactive', label: 'Inactive', count: 11 },
  ]}
  activeFilter="all"
  onFilterChange={(id) => setActiveFilter(id)}
  searchPlaceholder="Search workers…"
  onSearch={(q) => setQuery(q)}
  items={filteredItems}
  renderItem={(item) => <EntityRow key={item.id} {...item} />}
  emptyState={<EmptyState icon="Users" title="No workers yet" description="Add your first worker to get started." action={<Button>Add worker</Button>} />}
/>
```

Use `ListViewSection` when the screen has:
- A filter tab bar (All / Active / etc.)
- A search input
- A scrollable list of entity rows

If the screen is a dashboard, form, or detail view — don't use `ListViewSection`. Use `CardContainer` or raw layout directly inside `ScreenLayout`.

---

## Registering in App.tsx

App.tsx is append-only. Add exactly two lines:

```typescript
// 1. Import (add to the existing import block, alphabetical order)
import { MyNewScreen } from './screens/MyNewScreen'

// 2. Registry entry (add to the SCREENS array or equivalent registry object)
{ id: 'my-new-screen', label: 'My New Screen', component: MyNewScreen },
```

**Never:**
- Add new functions to App.tsx
- Add new routes
- Modify existing entries
- Restructure the file

---

## Naming conventions

| Thing | Convention | Example |
|---|---|---|
| Screen file | PascalCase | `WorkerManagementScreen.tsx` |
| Screen function | PascalCase = file name | `export function WorkerManagementScreen()` |
| Screen title prop | Sentence case | `"Worker management"` |
| Registry id | kebab-case | `'worker-management'` |
| Registry label | Title case | `'Worker Management'` |

---

## Screen checklist

- [ ] File in `src/screens/` with PascalCase name
- [ ] Named export (no `export default`)
- [ ] Wrapped in `<ScreenLayout>` with `title` prop
- [ ] No top-level `px-*` or `mx-*` (ScreenLayout owns outer spacing)
- [ ] ListViewSection used for filter + entity list patterns
- [ ] EmptyState component used for zero-results (not a custom `<p>`)
- [ ] All colors via `var(--token-name)` — no hardcoded hex
- [ ] App.tsx: one import + one registry entry added (no other changes)
- [ ] DS-GAP filed for any element that uses `experimental/` components
