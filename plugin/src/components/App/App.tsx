import React from 'react';
import { Route, Routes } from 'react-router-dom';
import { ROUTES } from '../../constants';

const EntrypointPage = React.lazy(() => import('../../pages/EntrypointPage'));

function App() {
  return (
    <Routes>
      <Route path={ROUTES.Entrypoint} element={<EntrypointPage />} />
    </Routes>
  );
}

export default App;
