import { Period } from './period';

export interface Worker {
  readonly id: string;
  readonly url: string;
  readonly period: Period;
}
