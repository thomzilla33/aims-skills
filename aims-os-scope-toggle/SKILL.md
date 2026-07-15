---
name: aims-os-scope-toggle
description: Use when building or placing the version scope toggle UI component inside an AIMS-OS prototype. Use when a prototype needs the V1/V1.5/Full Vision switcher, when you need the React version of the scope toggle, or when customizing toggle behavior (e.g. adding a tier, styling it differently, or wiring it to callout annotations). Always use aims-os-feature-versioning first to understand the full versioning system.
---

# AIMS-OS Scope Toggle

The scope toggle is the floating control that lets engineering teams switch between delivery tiers inside a prototype. This skill covers the component itself — for the broader versioning system (tagging elements, version-map.md, callouts), see `aims-os-feature-versioning`.

---

## HTML Prototype Toggle (canonical)

Drop this before `</body>` in any versioned HTML prototype. No dependencies needed.

```html
<div id="version-toggle" style="
  position: fixed; top: 16px; right: 16px; z-index: 9999;
  display: flex; align-items: center; gap: 8px;
  background: #13151A; border: 1px solid #2A2D35;
  border-radius: 8px; padding: 6px 10px;
  font-family: Inter, sans-serif; font-size: 12px; color: #94a3b8;
  box-shadow: 0 4px 16px rgba(0,0,0,0.4);
">
  <span style="font-weight: 600; color: #e2e8f0; letter-spacing: 0.02em;">Scope</span>
  <div style="display: flex; gap: 4px;" role="group" aria-label="Feature scope selector">
    <button onclick="setScope('v1')" id="scope-v1"
      style="padding: 3px 10px; border-radius: 5px; border: 1px solid #2563EB;
             background: #2563EB; color: white; font-size: 11px; cursor: pointer; font-weight: 600;
             transition: all 0.15s;">
      V1
    </button>
    <button onclick="setScope('v1.5')" id="scope-v1.5"
      style="padding: 3px 10px; border-radius: 5px; border: 1px solid #2A2D35;
             background: transparent; color: #94a3b8; font-size: 11px; cursor: pointer;
             transition: all 0.15s;">
      V1.5
    </button>
    <button onclick="setScope('v2')" id="scope-v2"
      style="padding: 3px 10px; border-radius: 5px; border: 1px solid #2A2D35;
             background: transparent; color: #94a3b8; font-size: 11px; cursor: pointer;
             transition: all 0.15s;">
      Full vision
    </button>
  </div>
</div>

<script>
const SCOPE_TIERS = ['v1', 'v1.5', 'v2'];

function setScope(selected) {
  const selectedIndex = SCOPE_TIERS.indexOf(selected);

  // Show/hide versioned elements
  document.querySelectorAll('[data-version]').forEach(el => {
    const tier = el.getAttribute('data-version');
    if (tier === 'deferred') return;
    el.style.display = SCOPE_TIERS.indexOf(tier) <= selectedIndex ? '' : 'none';
  });

  // Show callouts only in tiers where the real element is hidden
  document.querySelectorAll('[data-callout-for]').forEach(el => {
    const calloutTier = el.getAttribute('data-callout-for');
    const calloutIndex = SCOPE_TIERS.indexOf(calloutTier);
    el.style.display = selectedIndex < calloutIndex ? '' : 'none';
  });

  // Update button styles
  SCOPE_TIERS.forEach(tier => {
    const btn = document.getElementById('scope-' + tier);
    if (!btn) return;
    const active = tier === selected;
    btn.style.background = active ? '#2563EB' : 'transparent';
    btn.style.color = active ? 'white' : '#94a3b8';
    btn.style.borderColor = active ? '#2563EB' : '#2A2D35';
    btn.style.fontWeight = active ? '600' : '400';
  });

  // Store scope in sessionStorage for cross-page persistence
  try { sessionStorage.setItem('aims-scope', selected); } catch(e) {}
}

// Restore scope from session or default to V1
const savedScope = (() => { try { return sessionStorage.getItem('aims-scope'); } catch(e) { return null; } })();
setScope(savedScope && SCOPE_TIERS.includes(savedScope) ? savedScope : 'v1');
</script>
```

---

## Variants

### Two-tier only (V1 / Full Vision)

When there's no intermediate expansion phase, drop the V1.5 button:

```html
<!-- Replace the button group with: -->
<div style="display: flex; gap: 4px;" role="group">
  <button onclick="setScope('v1')" id="scope-v1" ...>V1</button>
  <button onclick="setScope('v2')" id="scope-v2" ...>Full vision</button>
</div>
<!-- And change SCOPE_TIERS = ['v1', 'v2']; -->
```

### Custom tier names

Use custom labels when V1/V1.5/V2 isn't meaningful to stakeholders:

```html
<button onclick="setScope('mvp')">MVP</button>
<button onclick="setScope('launch')">Launch</button>
<button onclick="setScope('growth')">Growth</button>
<!-- SCOPE_TIERS = ['mvp', 'launch', 'growth']; -->
<!-- Elements use data-version="launch" or data-version="growth" -->
```

### Inline (non-floating) toggle

When the prototype already has a topbar and fixed positioning conflicts, use an inline version inside the topbar:

```html
<div style="display: flex; align-items: center; gap: 6px; margin-left: auto;">
  <span style="font-size: 11px; color: #64748b; font-weight: 500;">Scope:</span>
  <!-- same buttons as above -->
</div>
```

---

## React Component

```jsx
// components/common/ScopeToggle.jsx
import { useScope } from '../../state/ScopeContext'

const TIERS = [
  { id: 'v1', label: 'V1' },
  { id: 'v1.5', label: 'V1.5' },
  { id: 'v2', label: 'Full vision' },
]

export function ScopeToggle() {
  const { scope, setScope } = useScope()
  return (
    <div className="fixed top-4 right-4 z-[9999] flex items-center gap-2
                    bg-[#13151A] border border-[#2A2D35] rounded-lg px-3 py-1.5
                    shadow-lg" role="group" aria-label="Feature scope">
      <span className="text-xs font-semibold text-slate-200">Scope</span>
      <div className="flex gap-1">
        {TIERS.map(tier => (
          <button
            key={tier.id}
            onClick={() => setScope(tier.id)}
            className={`px-2.5 py-0.5 rounded text-[11px] font-medium transition-all border
              ${scope === tier.id
                ? 'bg-aims-blue border-aims-blue text-white font-semibold'
                : 'bg-transparent border-[#2A2D35] text-slate-400 hover:text-slate-200'
              }`}
          >
            {tier.label}
          </button>
        ))}
      </div>
    </div>
  )
}
```

```jsx
// state/ScopeContext.jsx
import { createContext, useContext, useState } from 'react'

const ScopeContext = createContext(null)
const TIERS = ['v1', 'v1.5', 'v2']

export function ScopeProvider({ children }) {
  const [scope, setScope] = useState('v1')
  const tierIndex = (tier) => TIERS.indexOf(tier)
  const includes = (tier) => tierIndex(scope) >= tierIndex(tier)
  return (
    <ScopeContext.Provider value={{ scope, setScope, includes }}>
      {children}
    </ScopeContext.Provider>
  )
}

export const useScope = () => useContext(ScopeContext)
```

```jsx
// Usage inside any component:
const { includes } = useScope()
{includes('v1.5') && <AdvancedFiltersButton />}
{includes('v2') && <BulkActionsBar />}
```

---

## Toggle placement rules

- **HTML prototypes**: always `position: fixed; top: 16px; right: 16px; z-index: 9999`
- **React prototypes**: always `className="fixed top-4 right-4 z-[9999]"`
- The toggle must never be inside an `overflow: hidden` container — it will be clipped
- On mobile viewports (< 640px), move to `bottom: 16px; right: 16px` to avoid the topbar

---

## Scope persistence

The HTML version stores the selected scope in `sessionStorage` — switching pages within the same prototype session remembers the scope. This means engineers can navigate through a multi-page flow and stay in V1 mode without resetting.

The React version uses Context, which resets on page reload. If persistence across reloads matters, initialize from `sessionStorage` in `ScopeProvider`.
