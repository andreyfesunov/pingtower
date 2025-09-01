import { useState, useCallback, useMemo } from 'react';
import { AppPluginMeta } from '@grafana/data';
import { CreateUrlRequestModel } from 'requests/create_url_request.model';
import { Worker } from 'models/worker';
import { ApiClient, PluginConfig } from 'api/client';
import { URLsAPI } from 'api/urls';

export const useUrls = (pluginMeta: AppPluginMeta<PluginConfig>) => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const urlsApi = useMemo(() => {
    try {
      const apiClient = new ApiClient(pluginMeta);
      return new URLsAPI(apiClient);
    } catch (err) {
      console.error('Failed to create URLs API:', err);
      return null;
    }
  }, [pluginMeta]);

  const isConfigured = useMemo(() => {
    return Boolean(pluginMeta.jsonData?.apiUrl);
  }, [pluginMeta.jsonData?.apiUrl]);

  const createUrl = useCallback(
    async (model: CreateUrlRequestModel): Promise<Worker> => {
      if (!urlsApi) {
        throw new Error('URLs API is not configured');
      }

      try {
        setLoading(true);
        setError(null);
        const worker = await urlsApi.create(model);
        return worker;
      } catch (err) {
        const errorMessage = err instanceof Error ? err.message : 'Failed to create URL';
        setError(errorMessage);
        console.error('Error creating URL:', err);
        throw err;
      } finally {
        setLoading(false);
      }
    },
    [urlsApi]
  );

  return {
    loading,
    error,
    isConfigured,
    createUrl,
    clearError: () => setError(null),
  };
};

