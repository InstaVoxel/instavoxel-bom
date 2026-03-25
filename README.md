# BOM Document — Portable Package

Self-contained BOM component package. Copy this folder into any React + Tailwind project, run setup, and it works identically.

## Prerequisites

- Node.js 18+
- React 18+
- Tailwind CSS 3.4+
- TypeScript 5+

## Quick Start (standalone preview)

```bash
cd bom-portable
npm install
npm run dev
# → http://localhost:5173
```

This starts a Vite dev server showing all 3 BOM versions (English, Chinese, Bilingual).

## Integration into existing project

### Step 1: Copy files

Copy `components/` folder into your project.

### Step 2: Import CSS (order matters)

```tsx
import './path-to/components/Design_Sys_style.css';  // design tokens — FIRST
import './path-to/components/documents.css';           // document tokens — SECOND
```

### Step 3: Tailwind config

Add the components path to your `tailwind.config.js`:

```js
content: [
  // ... your existing paths
  './path-to/components/**/*.{ts,tsx}',
],
```

### Step 4: Google Fonts

Add to your `index.html` `<head>`:

```html
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet" />
```

### Step 5: Use the component

```tsx
import { BomDocument, type BomData } from './components/BomDocument';

const data: BomData = {
  orderId: 'Q1211263U 噴火槍',
  date: '2026-01-15',
  itemCount: 3,
  totalParts: 10,
  parts: [
    {
      partId: '噴火槍_P01',
      dimsMm: '127 × 89 × 45',
      dimsIn: '5.00 × 3.50 × 1.77',
      weight: '342 g',
      qty: 5,
      filename: 'Assembly.stp',
      specs: [
        { label: 'Process', value: 'CNC Machining', valueZh: 'CNC 加工' },
        { label: 'Material', value: 'Aluminum 6061-T6', valueZh: '鋁合金 6061-T6' },
        { label: 'Finish', value: 'Standard', valueZh: '標準' },
        { label: 'Tolerance', value: '±0.05mm' },
      ],
      notes: ['參見 PDF #1: 角度要求'],
    },
  ],
};

// English
<BomDocument data={data} />

// Chinese
<BomDocument data={data} lang="zh" />

// Bilingual
<BomDocument data={data} lang="zh-en" />
```

## Language modes

| `lang` prop | Labels | Values | Headers |
|-------------|--------|--------|---------|
| `'en'` (default) | English | `value` | English |
| `'zh'` | Chinese | `valueZh` (fallback `value`) | Chinese |
| `'zh-en'` | Chinese + English (inline) | Chinese above + English below (stacked) | Chinese above + English below |

## Print

- `Ctrl+P` outputs exactly what you see on screen
- Colors, backgrounds, borders all preserved via `print-color-adjust: exact`
- Table rows won't split across pages (`break-inside: avoid`)
- Table header does NOT repeat on each printed page (by design)

## File inventory

```
bom-portable/
├── components/
│   ├── BomDocument.tsx        ← Main component (types + 3 lang modes)
│   ├── DocumentHeader.tsx     ← Purple brand header band
│   ├── DocumentFooter.tsx     ← Footer with doc ID + page number
│   ├── Icons_Print.tsx        ← INSTAVOXEL logo SVG
│   ├── Design_Sys_style.css   ← Design token system (colors, spacing, radii)
│   └── documents.css          ← Document-specific tokens (text sizes, page layout)
├── demo/
│   ├── index.html
│   ├── src/
│   │   ├── main.tsx           ← Entry point
│   │   ├── BomDemo.tsx        ← Sample data + 3-version preview
│   │   └── index.css          ← Tailwind + print styles
│   ├── package.json
│   ├── tsconfig.json
│   ├── tailwind.config.js
│   ├── postcss.config.js
│   └── vite.config.ts
└── README.md
```
