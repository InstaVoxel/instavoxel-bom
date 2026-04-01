import React, { useState, useEffect, lazy, Suspense } from 'react';
import ReactDOM from 'react-dom/client';
import '../../components/Design_Sys_style.css';
import '../../components/documents.css';
import './index.css';

const BomDemo = lazy(() => import('./BomDemo'));
const FactoryBomDemo = lazy(() => import('./FactoryBomDemo'));

function Router() {
  const [hash, setHash] = useState(window.location.hash || '#/');
  useEffect(() => {
    const onHash = () => setHash(window.location.hash || '#/');
    window.addEventListener('hashchange', onHash);
    return () => window.removeEventListener('hashchange', onHash);
  }, []);

  return (
    <Suspense fallback={null}>
      {(() => {
        switch (hash.replace(/\?.*$/, '')) {
          case '#/factory-bom': return <FactoryBomDemo />;
          case '#/bom':         return <BomDemo />;
          default: return (
            <div style={{ maxWidth: 400, margin: '80px auto', fontFamily: 'Inter, system-ui, sans-serif' }}>
              <h1 style={{ fontSize: 18, fontWeight: 600, marginBottom: 24 }}>BOM Documents</h1>
              <nav style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
                <a href="#/bom" style={{ textDecoration: 'none', color: '#2E0D77', fontWeight: 500 }}>
                  BOM — Bill of Materials (EN/ZH/Bilingual)
                </a>
                <a href="#/factory-bom" style={{ textDecoration: 'none', color: '#2E0D77', fontWeight: 500 }}>
                  Factory BOM — RFQ BOM 工廠報價用 (v2)
                </a>
              </nav>
            </div>
          );
        }
      })()}
    </Suspense>
  );
}

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <Router />
  </React.StrictMode>
);
