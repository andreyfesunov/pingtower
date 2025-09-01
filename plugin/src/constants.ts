import pluginJson from './plugin.json';

export const PLUGIN_BASE_URL = `/a/${pluginJson.id}`;

export enum ROUTES {
  List = 'list',
  Create = 'create',
  CreateWithURL = 'create/url',
  CreateWithAPI = 'create/api',
}
