# BOM Portable — Integration Guide
# 遷移到目標專案時，需要調整的所有項目

> 本文件列出所有**會因目標位置而變動或衝突**的項目。
> 每項標註嚴重度：`[必改]` = 不改會壞、`[可能衝突]` = 視目標專案而定、`[建議]` = 最佳實踐

---

## 1. 路徑類 — 必須根據放置位置調整

### 1.1 `[必改]` BomDemo.tsx 的 import 路徑

```
檔案: demo/src/BomDemo.tsx (Line 8)
```

```tsx
// 目前（假設 components/ 與 demo/ 同層級）：
import { BomDocument } from '../../components/BomDocument';

// 如果你把 components/ 放到別的位置，必須改：
import { BomDocument } from '放你的實際相對路徑/BomDocument';
```

**判斷方法**：從使用 BomDocument 的檔案出發，計算到 `components/BomDocument.tsx` 的相對路徑。

---

### 1.2 `[必改]` main.tsx 的 CSS import 路徑

```
檔案: demo/src/main.tsx (Line 3-4)
```

```tsx
// 目前：
import '../../components/Design_Sys_style.css';  // ← 路徑取決於 components/ 放哪
import '../../components/documents.css';          // ← 同上

// 改成你的實際路徑，且順序不能變：
import '你的路徑/Design_Sys_style.css';  // 必須第一個
import '你的路徑/documents.css';          // 必須第二個
```

**順序很重要**：`Design_Sys_style.css` 定義了 `documents.css` 引用的 token（如 `--gray-175`、`--shadow-lg`），順序反了會導致變數未定義。

---

### 1.3 `[必改]` tailwind.config.js 的 content 路徑

```
檔案: demo/tailwind.config.js (Line 5)
```

```js
content: [
  './index.html',
  './src/**/*.{ts,tsx}',
  '../components/**/*.{ts,tsx}',  // ← 改為你的 components/ 實際路徑
],
```

**不改的後果**：Tailwind 掃不到元件檔案 → 所有 Tailwind arbitrary value class（如 `text-[length:var(--doc-text-body)]`）不會生成 → 頁面無樣式。

---

### 1.4 `[必改]` tsconfig.json 的 include 路徑

```
檔案: demo/tsconfig.json (Line 16)
```

```json
"include": ["src", "../components"]  // ← 改為你的 components/ 實際路徑
```

**不改的後果**：TypeScript 編譯器找不到元件檔案 → type-check 報錯。

---

## 2. CSS 衝突類 — 視目標專案既有樣式而定

### 2.1 `[可能衝突]` CSS Custom Properties (`:root` 變數)

```
檔案: components/Design_Sys_style.css
影響: 所有以 -- 開頭的 CSS 變數名
```

**定義了大量 `:root` 變數**，如果目標專案也用了同名變數會被覆蓋：

| 變數前綴 | 數量 | 衝突風險 |
|---------|------|---------|
| `--color-primary-*` | 6 個 | 高 — 常見命名 |
| `--gray-*` (50~950) | 15 個 | 高 — 常見命名 |
| `--color-success/error/warning/info` | 8 個 | 高 — 常見命名 |
| `--sp-*` (1~12) | 10 個 | 中 |
| `--text-*` (xxs~2xl) | 7 個 | 中 |
| `--radius-*`, `--shadow-*`, `--h-*` | 15 個 | 低 |
| `--font` | 1 個 | 中 |

**處理方式**：
- **無衝突**：直接用，不需改
- **有衝突**：把 `Design_Sys_style.css` 的 `:root` 塊用更具體的 scope 包裹：
  ```css
  /* 改為只作用於 doc-page 內部 */
  .doc-page {
    --color-primary: #2E0D77;
    --gray-50: #F7F6FB;
    /* ... 所有變數移到這裡 ... */
  }
  ```

---

### 2.2 `[可能衝突]` `documents.css` 的全域規則

```
檔案: components/documents.css
```

以下規則作用在**全域**，可能影響目標專案的其他頁面：

| 規則 | 行號 | 影響 | 處理方式 |
|------|------|------|---------|
| `@page { size: Letter; margin: 0; }` | 74 | 改變整個專案的列印紙張設定 | 如果目標專案有其他列印需求，移到 `@media print` 內並加 scope |
| `body { background: #FFF; margin: 0; }` (print) | 107-110 | 列印時 body 被強制白底 | 通常無害，但有其他列印頁面時需注意 |
| `body.doc-preview { ... }` (screen) | 118-124 | 只在 body 有 `doc-preview` class 時生效 | 安全 — 不加 class 就不觸發 |

---

### 2.3 `[可能衝突]` `index.css` 的列印規則

```
檔案: demo/src/index.css
```

| 規則 | 影響 | 處理方式 |
|------|------|---------|
| `* { print-color-adjust: exact !important; }` | 全域列印色彩保留 — 影響專案所有列印 | 改為 `.doc-page * { ... }` 限縮範圍 |
| `body { background: #FFF; padding: 0; margin: 0; }` (print) | 列印時重設 body | 與其他列印樣式衝突時需合併 |
| `tr { break-inside: avoid; }` | 全域所有表格行禁止斷頁 | 改為 `.doc-page tr { ... }` |

**建議整合方式**：把 `index.css` 的 `@media print` 內容都加上 `.doc-page` prefix：

```css
@media print {
  .doc-page {
    box-shadow: none !important;
    border-radius: 0 !important;
    page-break-before: always;
    break-before: page;
  }
  .doc-page * {
    -webkit-print-color-adjust: exact !important;
    print-color-adjust: exact !important;
  }
  .doc-page tr {
    page-break-inside: avoid;
    break-inside: avoid;
  }
}
```

---

### 2.4 `[可能衝突]` Tailwind Preflight (CSS Reset)

```
檔案: demo/src/index.css (Line 1)
```

```css
@tailwind base;  /* ← 這會注入 Tailwind 的 CSS reset */
```

**影響**：Tailwind preflight 會重設 `margin`、`padding`、`border`、`heading` 樣式。如果目標專案**不用 Tailwind**，引入這行會破壞既有樣式。

**處理方式**：
- 目標專案已用 Tailwind → 不需改，已有 preflight
- 目標專案不用 Tailwind → 刪除 `@tailwind base;`，手動引入需要的 reset，或在 `tailwind.config.js` 加 `corePlugins: { preflight: false }`

---

## 3. 字體類

### 3.1 `[必改]` Google Fonts 載入

```
檔案: demo/index.html (Line 6-8)
```

```html
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet" />
```

**必須確認目標專案有載入 Inter 字體**。如果沒有：
- 加上述三行到目標 `index.html` 的 `<head>`
- 或用 npm 包：`npm i @fontsource/inter` 然後 `import '@fontsource/inter'`

**不載入的後果**：fallback 到系統字體（Segoe UI / SF Pro），間距和字寬會偏移，表格對齊會跑掉。

---

### 3.2 `[可能衝突]` 品牌字體 "Realist Wide"

```
檔案: components/DocumentHeader.tsx (Line 57)
```

```tsx
style={{ fontFamily: '"Realist Wide", var(--font-sans)', fontWeight: 800 }}
```

Header 的 "INSTAVOXEL" 品牌字用 **Realist Wide**（商業授權字體）。如果目標環境沒裝這個字體，會 fallback 到 `var(--font-sans)`（Inter），外觀略有不同但不影響功能。

**處理方式**：不影響 BOM 功能，可忽略。如需完全一致，需取得 Realist Wide 字體授權。

---

## 4. HTML 入口類

### 4.1 `[必改]` Viewport meta

```
檔案: demo/index.html (Line 4)
```

```html
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
```

目標專案的 `index.html` **必須有這行**。沒有的話瀏覽器可能自動縮放到 80%，所有元件尺寸會偏。

---

### 4.2 `[建議]` body class

```
檔案: demo/index.html (Line 11)
```

```html
<body class="doc-preview">
```

`doc-preview` class 啟動灰底居中預覽模式。整合進目標專案時：
- 如果 BOM 在獨立頁面渲染 → 加 `doc-preview`
- 如果 BOM 嵌在其他 UI 內 → **不加**，自己控制外層容器

---

## 5. 元件內部 — 不需改的項目

以下路徑是**元件之間的相對引用**，只要 `components/` 資料夾結構不拆散就不需要改：

| 檔案 | import | 條件 |
|------|--------|------|
| `BomDocument.tsx` | `./DocumentHeader` | components/ 內 ✓ |
| `BomDocument.tsx` | `./DocumentFooter` | components/ 內 ✓ |
| `DocumentHeader.tsx` | `./Icons_Print` | components/ 內 ✓ |

**規則**：`components/` 資料夾作為整體搬遷，內部不需改任何路徑。

---

## 6. 快速 Checklist

整合時逐項確認：

```
□ 1. components/ 整個資料夾複製到目標位置
□ 2. 修改使用端 import 路徑指向 BomDocument.tsx
□ 3. 修改 CSS import 路徑（Design_Sys_style.css → documents.css 順序）
□ 4. tailwind.config.js content 加入 components/ 路徑
□ 5. tsconfig.json include 加入 components/ 路徑
□ 6. 確認 index.html 有 Inter 字體 <link> 和 viewport meta
□ 7. 檢查 CSS 變數是否與既有專案衝突（grep --color-primary / --gray-）
□ 8. 列印相關 CSS 規則加上 .doc-page scope（如有其他列印頁面）
□ 9. 確認 Tailwind preflight 不會破壞既有樣式
□ 10. 測試：螢幕渲染 + Ctrl+P 列印 = 完全一致
```
