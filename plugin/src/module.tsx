import React, { Suspense, lazy } from 'react';
import { AppPlugin, AppPluginMeta } from '@grafana/data';
import { LoadingPlaceholder } from '@grafana/ui';
import type { AppConfigProps } from './components/AppConfig/AppConfig';

const LazyApp = lazy(() => import('./components/App/App'));
const LazyAppConfig = lazy(() => import('./components/AppConfig/AppConfig'));

const App = ({ plugin }: { plugin: AppPluginMeta<any> }) => (
  <Suspense fallback={<LoadingPlaceholder text="" />}>
    <LazyApp pluginMeta={plugin} />
  </Suspense>
);

const AppConfig = (props: AppConfigProps) => (
  <Suspense fallback={<LoadingPlaceholder text="" />}>
    <LazyAppConfig {...props} />
  </Suspense>
);

export const plugin = new AppPlugin<{}>().setRootPage(({ meta }) => <App plugin={meta} />).addConfigPage({
  title: 'Configuration',
  icon: 'cog',
  body: AppConfig,
  id: 'configuration',
});
