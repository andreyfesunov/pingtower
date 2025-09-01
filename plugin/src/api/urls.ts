import { CreateUrlRequestModel } from 'requests/create_url_request.model';
import { Worker } from 'models/worker';
import { ApiClient } from './client';

export class URLsAPI {
  public readonly prefix = '/urls';

  public constructor(private readonly client: ApiClient) {}

  public create(model: CreateUrlRequestModel): Promise<Worker> {
    return this.client.post(`${this.prefix}`, model);
  }
}
