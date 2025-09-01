import { useState, useCallback, useMemo } from 'react';
import { AppPluginMeta } from '@grafana/data';
import { ApiClient, PluginConfig } from '../api/client';
import { WorkersAPI } from '../api/workers';
import { Worker } from 'models/worker';
import { PaginationRequest } from 'requests/pagination_request.model';
import { Paged } from 'models/paged';

export const useWorkers = (pluginMeta: AppPluginMeta<PluginConfig>) => {
  const [workers, setWorkers] = useState<readonly Worker[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [pagination, setPagination] = useState({
    page: 1,
    page_size: 10,
    total: 0,
  });

  const workersApi = useMemo(() => {
    try {
      const apiClient = new ApiClient(pluginMeta);
      return new WorkersAPI(apiClient);
    } catch (err) {
      console.error('Failed to create Workers API:', err);
      return null;
    }
  }, [pluginMeta]);

  const isConfigured = useMemo(() => {
    return Boolean(pluginMeta.jsonData?.apiUrl);
  }, [pluginMeta.jsonData?.apiUrl]);
  const fetchWorkers = useCallback(
    async (page: number = pagination.page, page_size: number = pagination.page_size) => {
      if (!workersApi) {
        setError('Workers API is not configured');
        return;
      }

      try {
        setLoading(true);
        setError(null);

        const request: PaginationRequest = { page, page_size };
        const response: Paged<Worker> = await workersApi.get(request);

        setWorkers(response.items);
        setPagination({
          page: response.pagination.page,
          page_size: response.pagination.page_size,
          total: response.pagination.total,
        });
      } catch (err) {
        const errorMessage = err instanceof Error ? err.message : 'Failed to fetch workers';
        setError(errorMessage);
        console.error('Error fetching workers:', err);
      } finally {
        setLoading(false);
      }
    },
    [workersApi, pagination.page, pagination.page_size]
  );

  const changePage = useCallback(
    (page: number) => {
      fetchWorkers(page, pagination.page_size);
    },
    [fetchWorkers, pagination.page_size]
  );

  const changeLimit = useCallback(
    (page_size: number) => {
      fetchWorkers(1, page_size);
    },
    [fetchWorkers]
  );

  return {
    workers,
    loading,
    error,
    pagination,
    isConfigured,
    fetchWorkers,
    changePage,
    changeLimit,
    clearError: () => setError(null),
    refresh: () => fetchWorkers(),
  };
};

