# BOM Document — Portable Package

Self-contained BOM component package. Copy this folder into any React + Tailwind project, run setup, and it works identically.

## Components

| Component | File | Description |
|-----------|------|-------------|
| BomDocument | `components/BomDocument.tsx` | Standard BOM (EN/ZH/Bilingual) |
| **FactoryBomDocument** | `components/FactoryBomDocument.tsx` | **RFQ BOM for factory quoting (v2)** |

## Prerequisites

- Node.js 18+
- React 18+
- Tailwind CSS 3.4+
- TypeScript 5+

## Quick Start (standalone preview)

```bash
cd demo
npm install
npm run dev
# → http://localhost:5173
#   #/bom         → Standard BOM
#   #/factory-bom → Factory RFQ BOM
```

## Run Tests

```bash
cd demo
npm run test:bom    # 48 tests for FactoryBomDocument logic
```

---

## Factory BOM (FactoryBomDocument) — Quick Reference

### Data Interface

```tsx
import { FactoryBomDocument, type FactoryBomData } from './components/FactoryBomDocument';

const data: FactoryBomData = {
  orderCode: 'U26033148F',             // ERP order code (footer docId)
  orderName: '噴火槍',                 // Chinese codename (title display)
  issueDate: '4 月 1 日 (三)',         // Header band
  replyDeadline: '4 月 7 日 下午4點',  // Red deadline text
  parts: [
    {
      partId: 'P01',                    // Use \n for sub-parts: "P02\n(1/2)"
      dimsMm: { l: 127, w: 89, h: 45 },// Auto-formats to "127 × 89 × 45"
      weight: 0.34,                     // Auto-formats to "0.34 kg"
      material: '鋁合金 6061-T6',
      finish: '黑色陽極氧化',           // '標準' → renders blank
      qtyTiers: [1, 5, 10],            // Drives sub-rows + summary tier count
    },
  ],
  // Optional:
  // notes: ['Custom note 1'],         // Override default 5 manufacturing notes
  // dfmLineCount: 6,                  // Override DFM blank lines (default 4)
};

<FactoryBomDocument ref={pdfRef} data={data} />
```

### Auto-Computed (do NOT pass manually)

| Display | Logic |
|---------|-------|
| 零件種類：N 種 | Unique base partIds (before `\n`) |
| 共 X / Y / Z 件 | Per-tier quantity sums across all parts |
| 方案一/二/三... | One per max(qtyTiers.length) |
| Pagination | Page 1: 5 rows, Page 2+: 7 rows |

### Full Documentation

See the 120-line file header in `components/FactoryBomDocument.tsx` for:
- Complete page layout diagram
- All CSS design token dependencies
- Column width constants
- Algorithm explanations
- Edge case handling

---

## Standard BOM (BomDocument) — Quick Reference

```tsx
import { BomDocument, type BomData } from './components/BomDocument';

<BomDocument data={data} />           // English
<BomDocument data={data} lang="zh" /> // Chinese
<BomDocument data={data} lang="zh-en" /> // Bilingual
```

See `demo/src/BomDemo.tsx` for full sample data.

---

## Integration into existing project

### Step 1: Copy `components/` folder

### Step 2: Import CSS (order matters)

```tsx
import './path-to/components/Design_Sys_style.css';  // design tokens — FIRST
import './path-to/components/documents.css';           // document tokens — SECOND
```

### Step 3: Tailwind config

```js
content: [
  './path-to/components/**/*.{ts,tsx}',
],
```

### Step 4: Google Fonts

```html
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet" />
```

## File inventory

```
├── components/
│   ├── BomDocument.tsx            ← Standard BOM (EN/ZH/Bilingual)
│   ├── FactoryBomDocument.tsx     ← Factory RFQ BOM v2 (with full inline docs)
│   ├── DocumentFooter.tsx
│   ├── DocumentHeader.tsx
│   ├── Icons_Print.tsx
│   ├── Design_Sys_style.css
│   └── documents.css
├── demo/
│   ├── src/
│   │   ├── main.tsx               ← Router: #/bom, #/factory-bom
│   │   ├── BomDemo.tsx
│   │   ├── FactoryBomDemo.tsx
│   │   └── __tests__/
│   │       └── factoryBom.test.ts ← 48 tests
│   └── package.json
└── README.md
```
