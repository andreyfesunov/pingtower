import React, { useEffect } from 'react';
import { PluginPage } from '@grafana/runtime';
import { Alert, Button, Card, Pagination, Select, LoadingPlaceholder, useStyles2, Dropdown, Menu } from '@grafana/ui';
import { Link } from 'react-router-dom';
import { css } from '@emotion/css';
import { useWorkers } from '../hooks/useWorkers';
import { ROUTES } from '../constants';
import { prefixRoute } from 'utils/utils.routing';
import { AppPluginMeta } from '@grafana/data';

interface ListPageProps {
  pluginMeta: AppPluginMeta<any>;
}

const ListPage: React.FC<ListPageProps> = ({ pluginMeta }) => {
  const styles = useStyles2(getStyles);
  const {
    workers,
    loading,
    error,
    pagination,
    isConfigured,
    fetchWorkers,
    changePage,
    changeLimit,
    clearError,
    refresh,
  } = useWorkers(pluginMeta);

  const handleDeleteWorker = async (workerId: string) => {
    if (window.confirm('Are you sure you want to delete this worker?')) {
      try {
        console.log('Deleting worker:', workerId);
      } catch (error) {
        console.error('Failed to delete worker:', error);
      }
    }
  };

  useEffect(() => {
    if (isConfigured) {
      fetchWorkers();
    }
  }, [isConfigured, fetchWorkers]);

  if (!isConfigured) {
    return (
      <PluginPage>
        <Alert title="Plugin Configuration Required" severity="warning" className={styles.alert}>
          Please configure the API URL in plugin settings before using this plugin.
          <br />
          <Button
            variant="primary"
            size="sm"
            onClick={() => (window.location.href = '/plugins/pingtower-app')}
            className={styles.configButton}
          >
            Go to Plugin Settings
          </Button>
        </Alert>
      </PluginPage>
    );
  }

  if (error) {
    return (
      <PluginPage>
        <Alert title="Error" severity="error" className={styles.alert}>
          {error}
          <br />
          <Button variant="secondary" size="sm" onClick={clearError} className={styles.retryButton}>
            Clear Error
          </Button>
        </Alert>
      </PluginPage>
    );
  }

  if (loading && workers.length === 0) {
    return (
      <PluginPage>
        <LoadingPlaceholder text="Loading workers..." />
      </PluginPage>
    );
  }

  return (
    <PluginPage>
      <div className={styles.header}>
        <h1>Workers</h1>
        <div className={styles.headerActions}>
          <Link to={prefixRoute(ROUTES.Create)}>
            <Button variant="primary" icon="plus">
              Create Worker
            </Button>
          </Link>
        </div>
      </div>

      <div className={styles.filters}>
        <Select
          options={[
            { label: '10 per page', value: 10 },
            { label: '25 per page', value: 25 },
            { label: '50 per page', value: 50 },
          ]}
          value={pagination.page_size}
          onChange={(option) => changeLimit(option.value || 10)}
          className={styles.limitSelect}
        />
      </div>

      <div className={styles.tableContainer}>
        <table className={styles.workersTable}>
          <thead>
            <tr>
              <th className={styles.actionsHeader}>Actions</th>
              <th className={styles.urlHeader}>URL</th>
              <th className={styles.periodHeader}>Period</th>
            </tr>
          </thead>
          <tbody>
            {workers.length > 0
              ? workers.map((worker) => (
                  <tr key={worker.id} className={styles.workerRow}>
                    <td className={styles.actionsCell}>
                      <Dropdown
                        overlay={
                          <Menu>
                            <Menu.Item label="Delete" icon="trash-alt" onClick={() => handleDeleteWorker(worker.id)} />
                          </Menu>
                        }
                      >
                        <Button variant="secondary" icon="ellipsis-v" size="sm" />
                      </Dropdown>
                    </td>
                    <td className={styles.urlCell}>
                      <div className={styles.urlValue}>{worker.url || 'N/A'}</div>
                    </td>
                    <td className={styles.periodCell}>
                      <div className={styles.periodValue}>{worker.period || 'N/A'}</div>
                    </td>
                  </tr>
                ))
              : null}
          </tbody>
        </table>

        {workers.length === 0 && !loading && <div className={styles.emptyState}>No workers found</div>}
      </div>

      {pagination.total > pagination.page_size && (
        <div className={styles.pagination}>
          <Pagination
            currentPage={pagination.page}
            numberOfPages={Math.ceil(pagination.total / pagination.page_size)}
            onNavigate={changePage}
            hideWhenSinglePage={true}
          />
        </div>
      )}

      <div className={styles.footer}>
        <Button variant="secondary" icon="sync" onClick={refresh} disabled={loading}>
          Refresh
        </Button>
        <span className={styles.totalCount}>Total: {pagination.total} workers</span>
      </div>
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
  headerActions: css`
    display: flex;
    gap: 12px;
  `,
  filters: css`
    display: flex;
    gap: 16px;
    margin-bottom: 16px;
    align-items: center;
  `,
  limitSelect: css`
    width: 150px;
  `,
  pagination: css`
    display: flex;
    justify-content: center;
    margin: 24px 0;
  `,
  footer: css`
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: 24px;
  `,
  totalCount: css`
    color: var(--grafana-colors-text-secondary);
    font-size: 14px;
  `,
  alert: css`
    margin-bottom: 16px;
  `,
  configButton: css`
    margin-top: 12px;
  `,
  retryButton: css`
    margin-top: 12px;
  `,
  tableContainer: css`
    overflow-x: auto;
    width: 100%;
  `,
  workersTable: css`
    width: 100%;
    min-width: 100%;
    border-collapse: collapse;
    font-size: 14px;
    table-layout: fixed;
  `,
  actionsHeader: css`
    width: 80px;
    text-align: center;
    padding: 12px 8px;
    border-bottom: 1px solid var(--grafana-colors-border-weak);
    font-weight: 600;
    color: var(--grafana-colors-text-primary);
  `,
  urlHeader: css`
    text-align: left;
    padding: 12px 16px;
    border-bottom: 1px solid var(--grafana-colors-border-weak);
    font-weight: 600;
    color: var(--grafana-colors-text-primary);
    width: auto;
  `,
  periodHeader: css`
    width: 120px;
    text-align: left;
    padding: 12px 16px;
    border-bottom: 1px solid var(--grafana-colors-border-weak);
    font-weight: 600;
    color: var(--grafana-colors-text-primary);
  `,
  workerRow: css`
    &:hover {
      background-color: var(--grafana-colors-background-secondary);
    }
  `,
  actionsCell: css`
    text-align: center;
    padding: 12px 8px;
    border-bottom: 1px solid var(--grafana-colors-border-weak);
  `,
  urlCell: css`
    padding: 12px 16px;
    border-bottom: 1px solid var(--grafana-colors-border-weak);
    width: auto;
  `,
  urlValue: css`
    font-family: monospace;
    color: var(--grafana-colors-text-primary);
    word-break: break-all;
    font-size: 14px;
  `,
  periodCell: css`
    padding: 12px 16px;
    border-bottom: 1px solid var(--grafana-colors-border-weak);
  `,
  periodValue: css`
    color: var(--grafana-colors-text-primary);
    font-size: 14px;
    font-weight: 500;
  `,
  emptyState: css`
    text-align: center;
    padding: 40px;
    color: var(--grafana-colors-text-secondary);
    font-style: italic;
  `,
});

export default ListPage;
