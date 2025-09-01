import React, { useState } from 'react';
import { PluginPage } from '@grafana/runtime';
import { 
  Button, 
  Card, 
  Field, 
  FieldSet, 
  Input, 
  Select, 
  Alert,
  useStyles2 
} from '@grafana/ui';
import { Link } from 'react-router-dom';
import { css } from '@emotion/css';
import { useUrls } from '../hooks/useUrls';
import { CreateUrlRequestModel } from 'requests/create_url_request.model';
import { AppPluginMeta } from '@grafana/data';
import { ROUTES } from '../constants';
import { prefixRoute } from 'utils/utils.routing';
import { Period } from 'models/period';

interface CreateWithURLPageProps {
  pluginMeta: AppPluginMeta<any>;
}

const PERIOD_OPTIONS = [
  { label: 'Minute', value: Period.Minute },
  { label: 'Hour', value: Period.Hour },
  { label: 'Day', value: Period.Day },
  { label: 'Week', value: Period.Week },
  { label: 'Month', value: Period.Month },
];

const CreateWithURLPage: React.FC<CreateWithURLPageProps> = ({ pluginMeta }) => {
  const styles = useStyles2(getStyles);
  const { loading, error, isConfigured, createUrl, clearError } = useUrls(pluginMeta);
  
  const [formData, setFormData] = useState({
    url: '',
    period: Period.Hour,
  });
  const [success, setSuccess] = useState(false);

  if (!isConfigured) {
    return (
      <PluginPage>
        <Alert
          title="Plugin Configuration Required"
          severity="warning"
          className={styles.alert}
        >
          Please configure the API URL in plugin settings before creating workers.
          <br />
          <Button 
            variant="primary" 
            size="sm" 
            onClick={() => window.location.href = '/plugins/pingtower-app'}
            className={styles.configButton}
          >
            Go to Plugin Settings
          </Button>
        </Alert>
      </PluginPage>
    );
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!formData.url.trim()) {
      return;
    }

    try {
      const requestModel: CreateUrlRequestModel = {
        url: formData.url.trim(),
        period: formData.period,
      };

      await createUrl(requestModel);
      setSuccess(true);
      setFormData({ url: '', period: Period.Hour });
      
      setTimeout(() => {
        window.location.href = prefixRoute(ROUTES.List);
      }, 2000);
    } catch (err) {
      console.error('Failed to create worker:', err);
    }
  };

  const handleInputChange = (field: string, value: string | number) => {
    setFormData(prev => ({
      ...prev,
      [field]: value,
    }));
    if (error) {
      clearError();
    }
    if (success) {
      setSuccess(false);
    }
  };

  const isValidUrl = (url: string) => {
    try {
      new URL(url);
      return true;
    } catch {
      return false;
    }
  };

  const isFormValid = formData.url.trim() && isValidUrl(formData.url.trim());

  return (
    <PluginPage>
      <div className={styles.header}>
        <h1>Create Worker from URL</h1>
        <Link to={prefixRoute(ROUTES.Create)}>
          <Button variant="secondary">
            Back to Create
          </Button>
        </Link>
      </div>

      {success && (
        <Alert
          title="Worker Created Successfully"
          severity="success"
          className={styles.alert}
        >
          Your worker has been created and will start monitoring the URL.
          <br />
          Redirecting to Workers list in 2 seconds...
        </Alert>
      )}

      {error && (
        <Alert
          title="Error"
          severity="error"
          className={styles.alert}
        >
          {error}
        </Alert>
      )}

      <Card>
        <form onSubmit={handleSubmit}>
          <FieldSet label="Worker Configuration">
            <Field 
              label="URL" 
              description="Enter the URL you want to monitor"
              required
            >
              <Input
                type="url"
                placeholder="https://example.com"
                value={formData.url}
                onChange={(e) => handleInputChange('url', e.currentTarget.value)}
                invalid={Boolean(formData.url.trim() && !isValidUrl(formData.url.trim()))}

                className={styles.urlInput}
              />
            </Field>

            <Field 
              label="Check Period" 
              description="How often should we check this URL?"
              className={styles.periodField}
            >
              <Select
                options={PERIOD_OPTIONS}
                value={formData.period}
                onChange={(option) => handleInputChange('period', option.value || Period.Hour)}
                className={styles.periodSelect}
              />
            </Field>

            <div className={styles.actions}>
              <Button 
                type="submit" 
                variant="primary"
                disabled={!isFormValid || loading}
              >
                {loading ? 'Creating...' : 'Create Worker'}
              </Button>
              
              <Button 
                type="button" 
                variant="secondary"
                onClick={() => setFormData({ url: '', period: Period.Hour })}
                disabled={loading}
              >
                Reset
              </Button>
            </div>
          </FieldSet>
        </form>
      </Card>

      <Card className={styles.infoCard}>
        <h3>What happens next?</h3>
        <ul>
          <li>Your worker will be created and added to the monitoring queue</li>
          <li>The URL will be checked according to the selected period</li>
          <li>You can view the status and results in the Workers list</li>
          <li>Notifications will be sent if the URL becomes unavailable</li>
        </ul>
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
  urlInput: css`
    width: 100%;
  `,
  periodField: css`
    margin-top: 16px;
  `,
  periodSelect: css`
    width: 300px;
  `,
  actions: css`
    display: flex;
    gap: 12px;
    margin-top: 24px;
  `,
  alert: css`
    margin-bottom: 16px;
  `,
  configButton: css`
    margin-top: 12px;
  `,
  infoCard: css`
    margin-top: 24px;
    
    h3 {
      margin-bottom: 12px;
    }
    
    ul {
      margin: 0;
      padding-left: 20px;
      
      li {
        margin-bottom: 8px;
      }
    }
  `,
});

export default CreateWithURLPage;