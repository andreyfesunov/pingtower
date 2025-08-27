import { PluginPage } from '@grafana/runtime';
import { Card } from '@grafana/ui';
import { ROUTES } from '../constants';
import React from 'react';
import { prefixRoute } from 'utils/utils.routing';

const Entrypoint: React.FC = () => (
  <PluginPage>
    <Card href={prefixRoute(ROUTES.URLs)} noMargin>
      <Card.Heading>URLs Management</Card.Heading>
      <Card.Description>Analyze any website by entering its URL</Card.Description>
    </Card>
    <Card href={prefixRoute(ROUTES.APIs)} noMargin>
      <Card.Heading>APIs Management</Card.Heading>
      <Card.Description>Upload OpenAPI/Swagger files to analyze API endpoints</Card.Description>
    </Card>
  </PluginPage>
);

export default Entrypoint;
