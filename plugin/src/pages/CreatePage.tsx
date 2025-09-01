import { PluginPage } from '@grafana/runtime';
import { Card, Button, useStyles2 } from '@grafana/ui';
import { css } from '@emotion/css';
import { ROUTES } from '../constants';
import React from 'react';
import { prefixRoute } from 'utils/utils.routing';
import { Link } from 'react-router-dom';

const CreatePage: React.FC = () => {
  const styles = useStyles2(getStyles);

  return (
    <PluginPage>
      <div className={styles.header}>
        <h1>Create Worker</h1>
        <Link to={prefixRoute(ROUTES.List)}>
          <Button variant="secondary">
            Back to List
          </Button>
        </Link>
      </div>

      <Card href={prefixRoute(ROUTES.CreateWithURL)} noMargin>
        <Card.Heading>URLs Management</Card.Heading>
        <Card.Description>Analyze any website by entering its URL</Card.Description>
      </Card>
      <Card href={prefixRoute(ROUTES.CreateWithAPI)} noMargin>
        <Card.Heading>APIs Management</Card.Heading>
        <Card.Description>Upload OpenAPI/Swagger files to analyze API endpoints</Card.Description>
      </Card>
    </PluginPage>
  );
};

const getStyles = () => ({
  header: css`
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 24px;
  `,
});

export default CreatePage;
