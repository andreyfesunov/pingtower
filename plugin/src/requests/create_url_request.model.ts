import { Period } from 'models/period';

export interface CreateUrlRequestModel {
  readonly url: string;
  readonly period: Period;
}
