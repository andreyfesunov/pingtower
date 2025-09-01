import { PaginationRequest } from 'requests/pagination_request.model';
import { ApiClient } from './client';
import { Paged } from 'models/paged';
import { Worker } from 'models/worker';

export class WorkersAPI {
  public readonly prefix = '/workers';

  public constructor(private readonly client: ApiClient) {}

  public get(model: PaginationRequest): Promise<Paged<Worker>> {
    return this.client.get<Paged<Worker>>(`${this.prefix}?page=${model.page}&page_size=${model.page_size}`);
  }
}

