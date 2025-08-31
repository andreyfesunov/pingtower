defmodule PingWorkers.Presentation.Requests.CreateUrlRequestModel do
  @moduledoc """
  Input model for `UrlsRouter`. Used to create `Worker`.

  The module contains function to validate and create `CreateUrlRequestModel`.
  """

  alias PingWorkers.Domain.Enums.PeriodType
  alias PingWorkers.Domain.ValueObjects.Url

  defstruct [:url, :period]

  @type t :: %__MODULE__{
          url: Url.t(),
          period: PeriodType.t()
        }

  @type new_result :: {:ok, t} | {:error, String.t()}

  @spec new(map()) :: new_result()
  def new(params) when is_map(params) do
    with {:ok, url} <- validate_url(params),
         {:ok, period} <- validate_period(params) do
      {:ok, %__MODULE__{url: url, period: period}}
    end
  end

  @spec validate_url(map()) :: {:ok, Url.t()} | {:error, String.t()}
  defp validate_url(params) do
    case get_value(params, "url") do
      nil -> {:error, "URL is required"}
      url when is_binary(url) -> Url.new(url)
      _ -> {:error, "URL must be a string"}
    end
  end

  @spec validate_period(map()) :: {:ok, PeriodType.t()} | {:error, String.t()}
  defp validate_period(params) do
    case get_value(params, "period") do
      nil ->
        {:error, "Period is required"}

      period when is_binary(period) ->
        PeriodType.from_string(period)

      _ ->
        {:error, "Period must be a string"}
    end
  end

  defp get_value(params, key) do
    Map.get(params, key) || Map.get(params, String.to_atom(key))
  end
end
