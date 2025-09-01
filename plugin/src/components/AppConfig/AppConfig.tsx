import React, { ChangeEvent, useState } from 'react';
import { lastValueFrom } from 'rxjs';
import { css } from '@emotion/css';
import { AppPluginMeta, GrafanaTheme2, PluginConfigPageProps, PluginMeta } from '@grafana/data';
import { getBackendSrv } from '@grafana/runtime';
import { Button, Field, FieldSet, Input, useStyles2, Alert } from '@grafana/ui';

type AppPluginSettings = {
  apiUrl?: string;
};

type State = {
  apiUrl: string;
  loading: boolean;
  error: string | null;
  success: boolean;
};

export interface AppConfigProps extends PluginConfigPageProps<AppPluginMeta<AppPluginSettings>> {}

const AppConfig = ({ plugin }: AppConfigProps) => {
  const s = useStyles2(getStyles);
  const { enabled, pinned, jsonData } = plugin.meta;
  const [state, setState] = useState<State>({
    apiUrl: jsonData?.apiUrl || '',
    loading: false,
    error: null,
    success: false,
  });

  const isSubmitDisabled = Boolean(!state.apiUrl);

  const onChange = (event: ChangeEvent<HTMLInputElement>) => {
    setState({
      ...state,
      [event.target.name]: event.target.value.trim(),
      error: null,
      success: false,
    });
  };

  const onSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (isSubmitDisabled || state.loading) {
      return;
    }

    setState(prev => ({ ...prev, loading: true, error: null, success: false }));

    try {
      await updatePluginAndReload(plugin.meta.id, {
        enabled,
        pinned,
        jsonData: {
          apiUrl: state.apiUrl,
        },
      });
      setState(prev => ({ ...prev, loading: false, success: true }));
    } catch (error) {
      console.error('Failed to save settings:', error);
      setState(prev => ({ 
        ...prev, 
        loading: false, 
        error: error instanceof Error ? error.message : 'Failed to save settings' 
      }));
    }
  };

  return (
    <form onSubmit={onSubmit}>
      <FieldSet label="API Settings">
        {state.error && (
          <Alert title="Error" severity="error" className={s.marginBottom}>
            {state.error}
          </Alert>
        )}
        
        {state.success && (
          <Alert title="Success" severity="success" className={s.marginBottom}>
            Settings saved successfully!
          </Alert>
        )}

        <Field label="API Url" description="The URL of your external API">
          <Input
            width={60}
            name="apiUrl"
            id="config-api-url"
            value={state.apiUrl}
            placeholder="http://localhost:4000"
            onChange={onChange}
            disabled={state.loading}
          />
        </Field>

        <div className={s.marginTop}>
          <Button 
            type="submit" 
            disabled={isSubmitDisabled || state.loading}
          >
            {state.loading ? 'Saving...' : 'Save API settings'}
          </Button>
        </div>
      </FieldSet>
    </form>
  );
};

export default AppConfig;

const getStyles = (theme: GrafanaTheme2) => ({
  colorWeak: css`
    color: ${theme.colors.text.secondary};
  `,
  marginTop: css`
    margin-top: ${theme.spacing(3)};
  `,
  marginBottom: css`
    margin-bottom: ${theme.spacing(3)};
  `,
});

const updatePluginAndReload = async (pluginId: string, data: Partial<PluginMeta<AppPluginSettings>>) => {
  try {
    console.log('Updating plugin settings:', { pluginId, data });
    await updatePlugin(pluginId, data);
    console.log('Plugin settings updated successfully');
  } catch (e) {
    console.error('Error while updating the plugin', e);
    throw e;
  }
};

const updatePlugin = async (pluginId: string, data: Partial<PluginMeta>) => {
  console.log('Making API request to:', `/api/plugins/${pluginId}/settings`);
  console.log('Request data:', data);
  
  const response = await getBackendSrv().fetch({
    url: `/api/plugins/${pluginId}/settings`,
    method: 'POST',
    data,
  });

  console.log('API response:', response);
  return lastValueFrom(response);
};
