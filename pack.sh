#!/usr/bin/env bash
# Pack BOM portable package — copies all required files from the monorepo
# Run from: BOM_Build_Automate/bom-portable/
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATES="$(cd "$SCRIPT_DIR/../../" && pwd)"
COMPONENTS="$TEMPLATES/components"
DESIGN_SYS="$TEMPLATES/../Design_Sys/Shared_Components/components"
DEMO_SRC="$TEMPLATES/demo"
OUT="$SCRIPT_DIR"

echo "=== Packing BOM Portable ==="

# ── Components ──
mkdir -p "$OUT/components"
cp "$COMPONENTS/BomDocument.tsx"     "$OUT/components/"
cp "$COMPONENTS/DocumentHeader.tsx"  "$OUT/components/"
cp "$COMPONENTS/DocumentFooter.tsx"  "$OUT/components/"
cp "$COMPONENTS/Icons_Print.tsx"     "$OUT/components/"
cp "$DESIGN_SYS/Design_Sys_style.css" "$OUT/components/"
cp "$COMPONENTS/documents.css"       "$OUT/components/"

echo "  ✓ components/ (6 files)"

# ── Demo ──
mkdir -p "$OUT/demo/src"
cp "$DEMO_SRC/index.html"            "$OUT/demo/"
cp "$DEMO_SRC/vite.config.js"        "$OUT/demo/"
cp "$DEMO_SRC/tsconfig.json"         "$OUT/demo/"
cp "$DEMO_SRC/tailwind.config.js"    "$OUT/demo/"
cp "$DEMO_SRC/postcss.config.js"     "$OUT/demo/"
cp "$DEMO_SRC/src/BomDemo.tsx"       "$OUT/demo/src/"
cp "$DEMO_SRC/src/index.css"         "$OUT/demo/src/"

echo "  ✓ demo/ (7 files)"

# ── Generate demo/package.json (minimal, only what BOM needs) ──
cat > "$OUT/demo/package.json" << 'PKGJSON'
{
  "name": "bom-portable-demo",
  "private": true,
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.3.1",
    "react-dom": "^18.3.1"
  },
  "devDependencies": {
    "@types/react": "^18.3.1",
    "@types/react-dom": "^18.3.1",
    "@vitejs/plugin-react": "^4.3.1",
    "autoprefixer": "^10.4.20",
    "postcss": "^8.4.47",
    "tailwindcss": "^3.4.14",
    "typescript": "^5.5.3",
    "vite": "^5.4.8"
  }
}
PKGJSON
echo "  ✓ demo/package.json"

# ── Generate demo/src/main.tsx (standalone, no router) ──
cat > "$OUT/demo/src/main.tsx" << 'MAINTSX'
import React from 'react';
import ReactDOM from 'react-dom/client';
import '../../components/Design_Sys_style.css';
import '../../components/documents.css';
import './index.css';
import BomDemo from './BomDemo';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <BomDemo />
  </React.StrictMode>
);
MAINTSX
echo "  ✓ demo/src/main.tsx"

# ── Fix tsconfig to point to sibling components/ ──
cat > "$OUT/demo/tsconfig.json" << 'TSCONFIG'
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "typeRoots": ["./node_modules/@types"]
  },
  "include": ["src", "../components"]
}
TSCONFIG

# ── Fix tailwind to scan sibling components/ ──
cat > "$OUT/demo/tailwind.config.js" << 'TWCFG'
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    './index.html',
    './src/**/*.{ts,tsx}',
    '../components/**/*.{ts,tsx}',
  ],
  theme: { extend: {} },
  plugins: [],
};
TWCFG

echo "  ✓ configs fixed for portable paths"
echo ""
echo "=== Done ==="
echo "To test:  cd $OUT/demo && npm install && npm run dev"
