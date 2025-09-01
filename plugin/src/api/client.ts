import axios, { AxiosInstance, AxiosRequestConfig, AxiosResponse } from 'axios';
import { AppPluginMeta } from '@grafana/data';

export interface PluginConfig {
  apiUrl?: string;
}

export class ApiClient {
  private readonly axiosInstance: AxiosInstance;

  constructor(pluginMeta: AppPluginMeta<PluginConfig>) {
    const apiUrl = pluginMeta.jsonData?.apiUrl;

    if (!apiUrl) {
      throw new Error('API URL is not configured. Please set it in plugin settings.');
    }

    this.axiosInstance = axios.create({
      baseURL: apiUrl,
      timeout: 10000,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    this.setupInterceptors();
  }

  private setupInterceptors() {
    this.axiosInstance.interceptors.request.use(
      (config) => {
        console.log(`Making request to: ${config.baseURL}${config.url}`);
        return config;
      },
      (error) => {
        console.error('Request error:', error);
        return Promise.reject(error);
      }
    );

    this.axiosInstance.interceptors.response.use(
      (response) => {
        console.log(`Response from ${response.config.url}:`, response.status);
        return response;
      },
      (error) => {
        console.error('Response error:', error.response?.status, error.message);

        if (error.response?.status === 404) {
          throw new Error('API endpoint not found. Please check your API URL.');
        }

        if (error.response?.status >= 500) {
          throw new Error('Server error. Please try again later.');
        }

        return Promise.reject(error);
      }
    );
  }

  async get<T = any>(url: string, config?: AxiosRequestConfig): Promise<T> {
    const response: AxiosResponse<T> = await this.axiosInstance.get(url, config);
    return response.data;
  }

  async post<T = any>(url: string, data?: any, config?: AxiosRequestConfig): Promise<T> {
    const response: AxiosResponse<T> = await this.axiosInstance.post(url, data, config);
    return response.data;
  }

  async put<T = any>(url: string, data?: any, config?: AxiosRequestConfig): Promise<T> {
    const response: AxiosResponse<T> = await this.axiosInstance.put(url, data, config);
    return response.data;
  }

  async delete<T = any>(url: string, config?: AxiosRequestConfig): Promise<T> {
    const response: AxiosResponse<T> = await this.axiosInstance.delete(url, config);
    return response.data;
  }

  async patch<T = any>(url: string, data?: any, config?: AxiosRequestConfig): Promise<T> {
    const response: AxiosResponse<T> = await this.axiosInstance.patch(url, data, config);
    return response.data;
  }

  static createFromConfig(pluginMeta: AppPluginMeta<PluginConfig>): ApiClient {
    return new ApiClient(pluginMeta);
  }
}

