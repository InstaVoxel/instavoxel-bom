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
