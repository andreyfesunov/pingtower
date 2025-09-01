import React from 'react';
import { Route, Routes } from 'react-router-dom';
import { ROUTES } from '../../constants';
import { AppPluginMeta } from '@grafana/data';

const ListPage = React.lazy(() => import('../../pages/ListPage'));
const CreatePage = React.lazy(() => import('../../pages/CreatePage'));
const CreateWithURLPage = React.lazy(() => import('../../pages/CreateWithURLPage'));

interface AppProps {
  pluginMeta: AppPluginMeta<any>;
}

function App({ pluginMeta }: AppProps) {
  return (
    <Routes>
      <Route path={ROUTES.List} element={<ListPage pluginMeta={pluginMeta} />} />
      <Route path={ROUTES.Create} element={<CreatePage />} />
      <Route path={ROUTES.CreateWithURL} element={<CreateWithURLPage pluginMeta={pluginMeta} />} />
    </Routes>
  );
}

export default App;
