export interface Paged<T> {
  readonly items: readonly T[];
  readonly pagination: PaginationSettings;
}

export interface PaginationSettings {
  readonly page: number;
  readonly page_size: number;
  readonly pages: number;
  readonly total: number;
  readonly has_next: boolean;
  readonly has_prev: boolean;
}
